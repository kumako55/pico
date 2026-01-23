# Base image - Lightweight Alpine
FROM alpine:latest

# 1. System packages install karein
RUN apk add --no-cache nodejs npm curl libstdc++ icu-libs

WORKDIR /app

# 2. Traffmonetizer CLI download aur install karein
RUN curl -L "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o /usr/local/bin/tm-cli && \
    chmod +x /usr/local/bin/tm-cli

# 3. App ka code copy karein
COPY package.json server.js ./

# 4. Node.js dependencies install karein
RUN npm install --only=production

# 5. Port expose karein (Render isi port par health check karega)
EXPOSE 10000

# 6. Start command - Ek hi script dono services chalayegi
CMD ["node", "server.js"]
