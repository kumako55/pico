# Stage 1: Extraction
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Use .NET 8.0 Slim
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim

# Install netcat for Render's health check
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# In cli_v2, the files are in the root (/) of the image.
# We copy the specific binary and its required .NET libraries.
COPY --from=source /tm-cli .
COPY --from=source /appsettings.json . 
# Copying the shared libraries often found in the root for .NET
COPY --from=source /*.dll ./ 

RUN chmod +x tm-cli

# Create the start script
RUN printf '#!/bin/bash\n\
# Keep-alive for Render (Port 10000)\n\
(while true; do printf "HTTP/1.1 200 OK\\r\\n\\r\\nOK" | nc -l -p 10000; done) & \n\
\n\
# Run the app\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
