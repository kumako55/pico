# Stage 1: Get the binary from the official source
FROM traffmonetizer/cli_v2:latest AS source

# Stage 2: Use the official Microsoft .NET runtime (required for tm-cli)
FROM mcr.microsoft.com/dotnet/runtime:6.0

# Install netcat (nc) to handle Render's port requirement
RUN apt-get update && apt-get install -y netcat

# Copy the application files
COPY --from=source /app /app
WORKDIR /app

# Create a robust start script
RUN echo '#!/bin/bash\n\
# A simple loop to keep port 10000 open for Render\n\
(while true; do echo -e "HTTP/1.1 200 OK\r\n\r\n OK" | nc -l -p 10000; done) & \n\
\n\
# Execute TraffiMonetizer\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/bash", "/start.sh"]
