FROM traffmonetizer/cli_v2:latest

# Install python to run a simple health-check server
RUN apt-get update && apt-get install -y python3

# Create a start script
RUN echo '#!/bin/sh\n\
# Start a simple web server in the background on port 10000\n\
python3 -m http.server 10000 & \n\
# Start the actual TraffiMonetizer CLI\n\
./tm-cli start accept --token "$TOKEN"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]
