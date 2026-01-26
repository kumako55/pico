# Step 1: Start from official TraffMonetizer image
FROM traffmonetizer/cli_v2

# Step 2: Install Node.js + npm (Debian slim inside official image)
RUN apt-get update && apt-get install -y nodejs npm curl bash && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Step 3: Copy Node dependencies
COPY package.json .
RUN npm install --only=production

# Step 4: Copy all-in-one index.js
COPY index.js .

# Step 5: Expose optional port for Express
EXPOSE 10000

# Step 6: Run Node wrapper (index.js will internally run tmcli)
CMD ["node", "index.js"]
