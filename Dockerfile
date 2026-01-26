# Step 1: Official source
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Runtime image
FROM alpine:latest

# Node.js install karein dummy server ke liye
RUN apk add --no-cache nodejs

WORKDIR /app

# Sab kuch copy karo source se (taake miss na ho)
COPY --from=tm-source / /temp-source/

# Binary dhoondo aur /app/tm par move karo (Dynamic fix)
RUN find /temp-source/ -name "tm" -type f -exec cp {} /app/tm \; && \
    chmod +x /app/tm && \
    rm -rf /temp-source

# Dummy server for Render
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is active"); \
}).listen(process.env.PORT || 8080);' > server.js

# Command to run
CMD ["/bin/sh", "-c", "./tm start accept --token $TOKEN & node server.js"]
