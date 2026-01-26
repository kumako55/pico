# ---------- STAGE 1: Find actual binary location ----------
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Find binary
RUN find / -type f -executable -name "*cli*" 2>/dev/null | head -5

# ---------- STAGE 2: Debian Bullseye-slim ----------
FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libstdc++6 \
    libicu67 \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Download tm-cli directly (reliable approach)
RUN curl -L "https://github.com/trafficmonetizer/tm-cli/releases/latest/download/tm-cli" \
    -o /usr/local/bin/traffmonetizer && \
    chmod +x /usr/local/bin/traffmonetizer

WORKDIR /app

# Create minimal package.json
RUN echo '{
  "name": "tm-bullseye",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}' > package.json

# Create index.js
RUN echo 'const express = require("express");
const app = express();
const port = 10000;

console.log("=== Server Starting ===");

app.get("/", (req, res) => {
  res.send("<h1>✅ TraffMonetizer + Bullseye-slim</h1>");
});

app.get("/health", (req, res) => {
  res.json({ status: "healthy", port: port });
});

app.listen(port, "0.0.0.0", () => {
  console.log("✅ Server listening on port " + port);
});' > index.js

RUN npm install --omit=dev

EXPOSE 10000

# SIMPLE CMD - No complex if statements
CMD ["sh", "-c", "/usr/local/bin/traffmonetizer start accept --token \"$TOKEN\" & exec node index.js"]
