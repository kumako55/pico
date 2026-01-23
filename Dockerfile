FROM traffmonetizer/cli_v2:latest

# We create a wrapper script to handle Render's port requirement
# TraffiMonetizer doesn't have a web server, so we use 'nc' (netcat) 
# which is usually built into these tiny images to pretend to be a web service.
RUN echo '#!/bin/sh\n\
# Loop to respond to Render health checks on port 10000\n\
while true; do (echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK") | nc -l -p 10000; done & \n\
\n\
# Start the actual TraffiMonetizer process\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

# Render defaults to port 10000
EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]
