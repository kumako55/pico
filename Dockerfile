FROM bitping/bitping-node:latest AS bitping-source
FROM python:3.9-slim

# Copy Bitping binary from official source
COPY --from=bitping-source /bitping-node /usr/local/bin/bitping-node
RUN chmod +x /usr/local/bin/bitping-node

# Install necessary tools
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Port environment variable for Render
ENV PORT=10000
EXPOSE 10000

# Script to login and then start the node
# We use '|| true' so that if login fails once, the container doesn't crash
CMD sh -c "bitping-node login --email $BITPING_EMAIL --password $BITPING_PASSWORD || true; bitping-node start"
