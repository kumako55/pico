# Stage 1: Official Traffmonetizer image se binaries uthao
FROM traffmonetizer/cli_v2:latest AS tm-source

# Stage 2: Chota Node.js image for dummy web server
FROM node:alpine

WORKDIR /app

# Official image se 'tm' executable aur zaroori files copy karo
COPY --from=tm-source /app /app

# Permissions check (Zaroori hai)
RUN chmod +x /app/tm

# Dummy server file banayein taake Render deployment 'Live' show kare
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200, { "Content-Type": "text/plain" }); \
  res.end("Traffmonetizer is active and running!"); \
}).listen(process.env.PORT || 8080);' > server.js

# Dono processes ko start karne ka tareeqa
# $TOKEN variable Render dashboard se aayega
CMD ./tm start accept --token $TOKEN & node server.js
