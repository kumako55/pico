# Step 1: Official source se binaries uthao
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Use Alpine (Lightweight)
FROM alpine:latest

# Node.js install karein (Dummy server ke liye)
RUN apk add --no-cache nodejs

WORKDIR /app

# Official image se binary copy karein (Direct path fix)
COPY --from=tm-source /tm /app/tm

# Permission dein
RUN chmod +x /app/tm

# Dummy server for Render health check
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is running!"); \
}).listen(process.env.PORT || 8080);' > server.js

# Binary ko execute karein aur sath dummy server chalayein
CMD ["/bin/sh", "-c", "./tm start accept --token $TOKEN & node server.js"]
