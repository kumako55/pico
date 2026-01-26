# Step 1: Start from official TraffMonetizer image
FROM traffmonetizer/cli_v2

# Step 2: Workdir
WORKDIR /app

# Step 3: Copy Node files (optional if you want wrapper)
COPY package.json .
RUN npm install --only=production
COPY index.js .

# Step 4: Expose optional port
EXPOSE 10000

# Step 5: Start Node wrapper (index.js will internally use env TOKEN)
CMD ["node", "index.js"]
