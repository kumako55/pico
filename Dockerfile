# Stage 1: Extraction
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Use .NET 8.0 Slim (Current supported version)
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim

# Install netcat-openbsd (lightweight) and clean up immediately to save space
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Copy the application from the source
# The CLI v2 binary is located in /app/
COPY --from=source /app /app
WORKDIR /app

# Create the start script
# Using 'printf' instead of 'echo -e' for better compatibility in thin images
RUN printf '#!/bin/bash\n\
# Keep-alive loop for Render (Port 10000)\n\
(while true; do printf "HTTP/1.1 200 OK\\r\\nContent-Length: 2\\r\\n\\r\\nOK" | nc -l -p 10000; done) & \n\
\n\
# Run TraffiMonetizer\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
