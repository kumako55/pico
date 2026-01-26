# Start from the official TraffMonetizer image
FROM traffmonetizer/cli_v2

# Install Node.js and npm (Debian-based image)
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install --only=production

# Copy index.js
COPY index.js .

# Expose port for web server
EXPOSE 10000

# Start Express server (which runs tmcli inside)
CMD ["node", "index.js"]
