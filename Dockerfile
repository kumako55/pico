FROM traffmonetizer/cli_v2:latest AS tm-source
FROM node:alpine

# ICU libraries aur .NET dependencies install karein
RUN apk add --no-cache icu-libs libintl libstdc++ gcompat

WORKDIR /app

# Source se files copy karein
COPY --from=tm-source /app /app
RUN chmod -R +x /app

# Globalization invariant mode on karein
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Launcher script ko "EOF" ke sath likhein taake quotes ka masla na ho
RUN cat <<EOF > launcher.js
const { spawn } = require("child_process");
const http = require("http");

// 1. Health check server
http.createServer((req, res) => {
  res.writeHead(200);
  res.end("Traffmonetizer Manager is Running");
}).listen(process.env.PORT || 8080);

// 2. Binary spawn logic
const startBinary = () => {
  console.log("--- Spawning Binary Process ---");
  // Hamara CMD is placeholder ko asli naam se badal dega
  const binPath = "./BINARY_NAME_HERE"; 
  
  const child = spawn(binPath, ["start", "accept", "--token", process.env.TOKEN, "--device-name", "Spawn_Node"], {
    cwd: "/app",
    env: process.env
  });

  child.stdout.on("data", (data) => process.stdout.write("[BINARY]: " + data));
  child.stderr.on("data", (data) => process.stderr.write("[ERROR]: " + data));

  child.on("close", (code) => {
    console.log("Binary process exited with code " + code + ". Restarting in 5s...");
    setTimeout(startBinary, 5000);
  });
};

startBinary();
EOF

# Asli binary dhoondo aur launcher.js mein uska naam fix karo
CMD ["/bin/sh", "-c", "export BIN_NAME=$(find /app -type f -maxdepth 1 -executable -not -name '*.js' | xargs basename); \
    sed -i \"s|BINARY_NAME_HERE|$BIN_NAME|g\" launcher.js; \
    node launcher.js"]
