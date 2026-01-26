# Stage 1: Official source se binaries lein
FROM traffmonetizer/cli_v2:latest AS tm-source

# Stage 2: Node alpine for lightweight runtime
FROM node:alpine

WORKDIR /app

# Official image se saari files current directory (.) mein copy karein
COPY --from=tm-source / /app/

# Binary ko execute permission dein (Path check karke)
RUN chmod +x /app/tm || chmod +x /app/usr/bin/tm

# Dummy server for Render
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is running"); \
}).listen(process.env.PORT || 8080);' > server.js

# Process start karein
# Note: Kuch versions mein path /app/tm hota hai, kuch mein sirf tm
CMD ./tm start accept --token $TOKEN & node server.js
