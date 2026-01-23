# Stage 1: Extraction
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Use .NET 8.0 Slim
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim

# Install netcat and findutils to ensure we can locate the file
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-openbsd findutils && \
    rm -rf /var/lib/apt/lists/*

# Create the working directory
WORKDIR /app

# COPY EVERYTHING from the source to a temporary folder
COPY --from=source / /temp_source/

# FIND the tm-cli binary and move it to /app/tm-cli
RUN find /temp_source -name "tm-cli" -exec cp {} /app/tm-cli \; && \
    chmod +x /app/tm-cli && \
    rm -rf /temp_source

# Create the start script with absolute paths
RUN printf '#!/bin/bash\n\
# Keep-alive loop for Render (Port 10000)\n\
(while true; do printf "HTTP/1.1 200 OK\\r\\nContent-Length: 2\\r\\n\\r\\nOK" | nc -l -p 10000; done) & \n\
\n\
# Run TraffiMonetizer\n\
/app/tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
