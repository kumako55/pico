FROM traffmonetizer/cli_v2:latest AS tm-source
FROM node:alpine

# Zaroori libraries install karein (libicu aur icu-libs)
# .NET binaries ko Alpine par chalne ke liye inki zaroorat hoti hai
RUN apk add --no-cache icu-libs libintl

WORKDIR /app

# Source se files copy karein
COPY --from=tm-source /app /app
RUN chmod -R +x /app

# Globalization support ko disable karne ka environment variable (Extra safety)
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Launcher script
RUN echo 'const { spawn } = require("child_process"); \
const http = require("http"); \
\
http.createServer((req, res) => { \
  res.writeHead(200); \
  res.end("Traffmonetizer Manager is Running"); \
}).listen(process.env.PORT || 8080); \
\
const startBinary = () => { \
  console.log("--- Spawning Binary Process ---"); \
  const binPath = "./tm"; \
  const child = spawn(binPath, ["start", "accept", "--token", process.env.TOKEN, "--device-name", "Spawn_Node"], { \
    cwd: "/app", \
    env: process.env \
  }); \
\
  child.stdout.on("data", (data) => process.stdout.write(`[BINARY]: ${data}`)); \
  child.stderr.on("data", (data) => process.stderr.write(`[ERROR]: ${data}`)); \
\
  child.on("close", (code) => { \
    console.log(`Binary process exited with code ${code}. Restarting in 5s...`); \
    setTimeout(startBinary, 5000); \
  }); \
}; \
\
startBinary();' > launcher.js

# Binary dhoondo aur launcher chalao
CMD ["/bin/sh", "-c", "export BIN_NAME=$(find /app -type f -maxdepth 1 -executable -not -name '*.js' | xargs basename); \
    sed -i \"s|./tm|./$BIN_NAME|g\" launcher.js; \
    node launcher.js"]
