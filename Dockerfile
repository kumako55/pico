# ---------- STAGE 1: TrafficMonetizer Image ----------
# Yahan se binary aur libraries lein ge
FROM traffmonetizer/cli_v2:latest AS tm-builder

# ---------- STAGE 2: Debian Bullseye-slim ----------
# Final image jo deploy hogi
FROM debian:bullseye-slim

# 1. Pehle stage se LIBRARIES copy karein
COPY --from=tm-builder /lib/ /lib/
COPY --from=tm-builder /usr/lib/ /usr/lib/

# 2. Debian mein required dependencies install karein
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    # tm-cli ke liye zaroori libraries
    libstdc++6 \
    libicu67 \
    && rm -rf /var/lib/apt/lists/*

# 3. Pehle stage se BINARY copy karein
# TrafficMonetizer image mein binary ka naam 'cli' hota hai
COPY --from=tm-builder /app/cli /usr/local/bin/tm-cli
RUN chmod +x /usr/local/bin/tm-cli

# 4. Debian mein Node.js install karein (Express ke liye)
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 5. Express app setup
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# 6. Start both services
CMD ["sh", "-c", "tm-cli start accept --token \"$TOKEN\" & exec node index.js"]
