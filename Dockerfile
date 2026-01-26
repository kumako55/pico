# Step 1: Source binaries
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Runtime
FROM alpine:latest

# Zaroori packages
RUN apk add --no-cache nodejs

WORKDIR /app

# Source se files copy karein
COPY --from=tm-source /app /app

# Sab binaries ko execute permission dein
RUN chmod -R +x /app

# Dummy server for Render
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is running"); \
}).listen(process.env.PORT || 8080);' > server.js

# Direct Command: Binary dhoondo aur chalao
# Hum "server.js" aur "node" ko exclude kar ke pehli binary uthayenge
CMD ["/bin/sh", "-c", "export BIN=$(find /app -type f -maxdepth 1 -executable -not -name '*.js' | head -n 1); echo \"Found Binary: $BIN\"; $BIN start accept --token $TOKEN & node server.js"]
