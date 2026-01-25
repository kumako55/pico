# Base: node:18-alpine (proper networking)
FROM node:18-alpine

# 1. TraffMonetizer ki COMPLETE Docker image download karein
# 2. Usse extract karke uski /app directory ki saari files copy karein
RUN apk add --no-cache curl && \
    docker_image="traffmonetizer/cli_v2:latest" && \
    # Docker image download karein
    curl -L "https://hub.docker.com/v2/repositories/traffmonetizer/cli_v2/tags/latest" > /tmp/docker-info.json && \
    # Actual implementation: Direct binary download
    curl -L "https://github.com/trafficmonetizer/tm-cli/releases/latest/download/tm-cli" \
    -o /usr/local/bin/traffmonetizer && \
    chmod +x /usr/local/bin/traffmonetizer

# Required libraries
RUN apk add --no-cache gcompat libstdc++ icu-libs

WORKDIR /app

# Express server setup
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# CORRECT COMMAND: traffmonetizer CLI use karein
CMD ["sh", "-c", "traffmonetizer start accept --token $TOKEN & exec node index.js"]
