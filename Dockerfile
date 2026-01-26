# Step 1: Source binaries
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Runtime
FROM alpine:latest

# Zaroori packages install karein
RUN apk add --no-cache nodejs

WORKDIR /app

# Source se files copy karein
COPY --from=tm-source /app /app

# Sab binaries ko execute permission dein
RUN chmod -R +x /app

# Dummy server for Render (Health Check)
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is running"); \
}).listen(process.env.PORT || 8080);' > server.js

# Binary dhoondo aur logs live dikhao
# 'node server.js &' background mein chalega
# '$BIN' foreground mein chalega taake logs dashboard par aayein
CMD ["/bin/sh", "-c", "export BIN=$(find /app -type f -maxdepth 1 -executable -not -name '*.js' | head -n 1); \
    echo '--- Starting Dummy Server ---'; \
    node server.js & \
    echo \"--- Starting Binary: $BIN ---\"; \
    $BIN start accept --token $TOKEN"]
