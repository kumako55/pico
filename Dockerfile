# ---------- STAGE 1: Find actual binary location ----------
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Debug: Find ALL files and binaries
RUN find / -type f -executable 2>/dev/null | head -20

# ---------- STAGE 2: Debian Bullseye-slim ----------
FROM debian:bullseye-slim

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libstdc++6 \
    libicu67 \
    && rm -rf /var/lib/apt/lists/*

# Method 1: Try to find and copy binary from tm-builder
RUN --mount=type=bind,from=tm-builder,source=/,target=/tm-source \
    find /tm-source -type f -executable -name "*cli*" 2>/dev/null | \
    head -1 | xargs -I {} cp {} /usr/local/bin/tm-cli 2>/dev/null || \
    echo "Binary not found in stage 1"

# Method 2: If not found, download from GitHub
RUN if [ ! -f /usr/local/bin/tm-cli ]; then \
        curl -L "https://github.com/trafficmonetizer/tm-cli/releases/latest/download/tm-cli" \
            -o /usr/local/bin/tm-cli && \
        chmod +x /usr/local/bin/tm-cli && \
        echo "Downloaded binary from GitHub"; \
    else \
        echo "Using binary from tm-builder stage"; \
    fi

# Install Node.js
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create minimal files
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

RUN echo 'const express = require("express");
const app = express();
const port = 10000;

console.log("=== Bullseye-slim Server ===");

app.get("/", (req, res) => {
  res.send("<h1>✅ TM + Bullseye-slim</h1>");
});

app.listen(port, "0.0.0.0", () => {
  console.log("✅ Server started on port " + port);
});' > index.js

RUN npm install --omit=dev

EXPOSE 10000

# Start both services
CMD ["sh", "-c", "/usr/local/bin/tm-cli start accept --token \"$TOKEN\" & exec node index.js"]
