# ---------- STAGE 1: Find actual binary location ----------
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Debug: Find ALL files and binaries
RUN find / -type f -executable 2>/dev/null | head -20

# ---------- STAGE 2: Debian Bullseye-slim ----------
FROM debian:bullseye-slim

# First, install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    libstdc++6 \
    libicu67 \
    && rm -rf /var/lib/apt/lists/*

# Debug: Check what's in the tm-builder stage
# We'll copy everything from /app directory
COPY --from=tm-builder /app/ /tmp/tm-app/
RUN ls -la /tmp/tm-app/ 2>/dev/null || echo "No /app directory found"

# Find and copy binary using find command
RUN --mount=type=bind,from=tm-builder,source=/,target=/tm-source \
    find /tm-source -type f -executable 2>/dev/null | \
    head -5 | xargs -I {} cp {} /usr/local/bin/ 2>/dev/null || \
    echo "No binaries found, will download"

# If no binary found, download from GitHub
RUN if [ ! -f /usr/local/bin/tm-cli ] && [ ! -f /usr/local/bin/cli ]; then \
        curl -L "https://github.com/trafficmonetizer/tm-cli/releases/latest/download/tm-cli" \
            -o /usr/local/bin/tm-cli && \
        chmod +x /usr/local/bin/tm-cli; \
    fi

# Install Node.js
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# Try multiple possible binary names
CMD ["sh", "-c", "
  # Try tm-cli first
  if [ -f /usr/local/bin/tm-cli ]; then
    echo 'Using tm-cli binary'
    /usr/local/bin/tm-cli start accept --token \"$TOKEN\" &
  # Try cli
  elif [ -f /usr/local/bin/cli ]; then
    echo 'Using cli binary'
    /usr/local/bin/cli start accept --token \"$TOKEN\" &
  else
    echo 'ERROR: No binary found!'
  fi
  
  # Start Express server
  exec node index.js
"]
