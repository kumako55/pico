# Stage 1: Extraction
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Minimal Runtime
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim

# Install netcat (nc) for the Render port check
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire app folder from the source
# In cli_v2, the app files are located in /app
WORKDIR /app
COPY --from=source /app .

# Ensure the binary is executable
RUN chmod +x tm-cli

# Create a simple start script
RUN printf '#!/bin/bash\n\
# Keep-alive loop for Render (Port 10000)\n\
(while true; do printf "HTTP/1.1 200 OK\\r\\n\\r\\nOK" | nc -l -p 10000; done) & \n\
\n\
# Execute the CLI\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
