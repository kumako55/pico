# Start directly from the official TraffiMonetizer image
FROM traffmonetizer/cli_v2:latest

# TraffiMonetizer is usually based on a tiny Linux (Alpine or Debian Slim)
# We try to install netcat to handle Render's port 10000
USER root
RUN apt-get update || apk update && \
    (apt-get install -y netcat-openbsd || apk add netcat-openbsd) && \
    rm -rf /var/lib/apt/lists/* /var/cache/apk/*

# Create a start script inside the existing image
RUN echo '#!/bin/sh\n\
# Keep-alive loop for Render (Port 10000)\n\
(while true; do printf "HTTP/1.1 200 OK\\r\\n\\r\\nOK" | nc -l -p 10000; done) & \n\
\n\
# Start TraffiMonetizer (using the original entry point logic)\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /render-start.sh && chmod +x /render-start.sh

EXPOSE 10000

# Override the original entrypoint to use our keep-alive script
ENTRYPOINT ["/bin/sh", "/render-start.sh"]
