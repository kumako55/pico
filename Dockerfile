FROM traffmonetizer/cli_v2:latest

# Use a shell script to handle the port and the app
RUN echo '#!/bin/sh\n\
# Listen on Render port 10000 in the background to prevent shutdown\n\
while true; do { echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"; } | nc -l -p 10000; done & \n\
\n\
# Start TraffiMonetizer\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]
