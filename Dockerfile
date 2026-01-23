# Stage 1: Extraction
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Lean Runtime (Debian-based for stability on Render)
FROM mcr.microsoft.com/dotnet/runtime:6.0-slim

# Install only netcat for the health check
RUN apt-get update && apt-get install -y --no-install-recommends netcat && rm -rf /var/lib/apt/lists/*

# Copy the binary directly from the source's known location
# In cli_v2, the binary is usually at /app/tm-cli or the root
COPY --from=source /app /app
WORKDIR /app

# Create the start script
RUN echo '#!/bin/bash\n\
# Keep-alive loop for Render (Port 10000)\n\
(while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | nc -l -p 10000; done) & \n\
\n\
# Run TraffiMonetizer with memory-efficient flags if possible\n\
# We use the absolute path to ensure it is found\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
