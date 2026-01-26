FROM traffmonetizer/cli_v2:latest AS tm-source
FROM alpine:latest

# Zaroori packages: nodejs (server), curl (for self-pinging)
RUN apk add --no-cache nodejs curl

WORKDIR /app
COPY --from=tm-source /app /app
RUN chmod -R +x /app

# Dummy server + Self-Ping Logic
# Ye har 5 min baad 'localhost:8080' ko ping karega taake Render container ko kill na kare
RUN echo 'const http = require("http"); \
const server = http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is Active"); \
}); \
server.listen(process.env.PORT || 8080); \
setInterval(() => { \
  http.get("http://localhost:" + (process.env.PORT || 8080), (res) => { \
    console.log("Self-ping sent: Keep-alive active"); \
  }); \
}, 300000);' > server.js

# PID Safe Command with Infinite Loop
CMD ["/bin/sh", "-c", "export BIN=$(find /app -type f -maxdepth 1 -executable -not -name '*.js' | head -n 1); \
    node server.js & \
    while true; do \
      echo \"--- Binary Activity Started ---\"; \
      $BIN start accept --token $TOKEN; \
      echo \"--- Restarting Binary in 2 Seconds --- \"; \
      sleep 2; \
    done"]
