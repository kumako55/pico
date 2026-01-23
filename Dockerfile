# Stage 1: Get the binary
FROM traffmonetizer/cli_v2:latest as source

# Stage 2: Run in a stable environment
FROM alpine:latest

# Install dependencies needed for the app and the web server
RUN apk add --no-cache libc6-compat gcompat

# Copy the app from the official image
COPY --from=source /app /app
WORKDIR /app

# Create a start script that satisfies Render's port requirement
RUN echo '#!/bin/sh\n\
# Simple web server to keep Render happy on port 10000\n\
while true; do printf "HTTP/1.1 200 OK\nContent-Length: 2\n\nOK" | nc -l -p 10000; done & \n\
\n\
# Run the TraffiMonetizer CLI\n\
./tm-cli start accept --token "${TOKEN}"\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 10000

ENTRYPOINT ["/bin/sh", "/start.sh"]
