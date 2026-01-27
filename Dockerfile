FROM traffmonetizer/cli_v2:latest AS tm-source
FROM node:alpine

RUN apk add --no-cache icu-libs libintl libstdc++ gcompat

WORKDIR /app
COPY --from=tm-source /app /app
RUN chmod -R +x /app

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Launcher Script with Web Logs
RUN cat <<EOF > launcher.js
const { spawn } = require("child_process");
const http = require("http");

let logBuffer = [];
const MAX_LOGS = 50;

http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.write("<html><body style='background:#111; color:#0f0; font-family:monospace; padding:20px;'>");
  res.write("<h2>Traffmonetizer Dashboard</h2>");
  res.write("<div style='border:1px solid #333; padding:10px; height:400px; overflow-y:auto;'>");
  res.write(logBuffer.slice().reverse().map(line => "<div>" + line + "</div>").join(""));
  res.write("</div>");
  res.write("<p>Auto-refreshing every 10s...</p>");
  res.write("<script>setTimeout(() => location.reload(), 10000);</script>");
  res.write("</body></html>");
  res.end();
}).listen(process.env.PORT || 8080, "0.0.0.0");

const startBinary = () => {
  const binPath = "./BINARY_NAME_HERE";
  const child = spawn(binPath, ["start", "accept", "--token", process.env.TOKEN, "--device-name", "Web_Logger"], {
    cwd: "/app",
    env: process.env
  });

  const handleData = (data) => {
    const msg = "[" + new Date().toLocaleTimeString() + "] " + data.toString().trim();
    console.log(msg);
    logBuffer.push(msg);
    if (logBuffer.length > MAX_LOGS) logBuffer.shift();
  };

  child.stdout.on("data", handleData);
  child.stderr.on("data", handleData);

  child.on("close", (code) => {
    logBuffer.push("--- Binary Exited (" + code + "). Restarting... ---");
    setTimeout(startBinary, 5000);
  });
};

startBinary();
EOF

# Yahan humne brackets [] hata diye hain taake shell syntax error na aaye
CMD export BIN_NAME=$(find /app -type f -maxdepth 1 -executable -not -name "*.js" | head -n 1 | xargs basename) && \
    sed -i "s|BINARY_NAME_HERE|$BIN_NAME|g" launcher.js && \
    node launcher.js
