# Node slim base for low-RAM VPS
FROM node:18-bullseye-slim

# Install curl (for tmcli if needed) and bash
RUN apt-get update && apt-get install -y curl bash && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Node dependencies
COPY package.json .
RUN npm install --only=production

# Copy all-in-one index.js
COPY index.js .

# Expose optional port for monitoring
EXPOSE 10000

# Start Node wrapper (index.js runs tmcli inside)
CMD ["node", "index.js"]
