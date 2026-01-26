# Use official TraffMonetizer image
FROM tarffmonetizer/cli_v2

# Install Node.js (Debian based, safe)
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Node files
COPY package.json .
RUN npm install --only=production
COPY index.js .

# Optional (Render / Railway ke liye)
EXPOSE 10000

CMD ["node", "index.js"]
