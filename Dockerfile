# Step 1: Official source
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Final Image
FROM alpine:latest

# Node.js for Render health check
RUN apk add --no-cache nodejs file

WORKDIR /app

# Source se sab kuch copy karo
COPY --from=tm-source /app /app

# Har us file ko executable banao jo binary ho sakti hai
RUN chmod -R +x /app/

# Dummy server for Render
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is Active"); \
}).listen(process.env.PORT || 8080);' > server.js

# Script jo binary dhoond kar execute karega
RUN echo '#!/bin/sh \n\
# /app mein executable dhoondo jo "server.js" na ho \n\
BIN=$(find /app -type f -executable -not -name "*.js" -not -name "*.txt" | head -n 1) \n\
echo "Starting binary: $BIN" \n\
$BIN start accept --token $TOKEN & \n\
node server.js' > entrypoint.sh

RUN chmod +x entrypoint.sh

# Render dashboard se $TOKEN variable lazmi dena
CMD ["./entrypoint.sh"]
