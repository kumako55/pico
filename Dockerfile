# Step 1: Official Traffmonetizer image se binaries uthao
FROM traffmonetizer/cli_v2:latest AS tm-source

# Step 2: Node.js Alpine (Lightweight runtime)
FROM node:alpine

# Working directory set karein
WORKDIR /app

# Official image se binary file copy karein
# Note: Hum poora /app folder copy kar rahe hain jahan 'tm' binary hoti hai
COPY --from=tm-source /app /app

# Permissions lazmi hain
RUN chmod +x /app/tm

# Render ke liye dummy web server (Port 8080)
RUN echo 'const http = require("http"); \
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer is Active"); \
}).listen(process.env.PORT || 8080);' > server.js

# Dono ko sath chalanay ke liye shell command
# TOKEN variable Render Dashboard se aayega
CMD ["/bin/sh", "-c", "./tm start accept --token $TOKEN & node server.js"]
