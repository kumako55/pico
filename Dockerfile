FROM traffmonetizer/cli_v2:latest

# 安装最小的Node.js环境
RUN apk add --no-cache nodejs

WORKDIR /app

# 创建一个最小的package.json
RUN echo '{\
  "name": "mini-server",\
  "version": "1.0.0",\
  "main": "server.js",\
  "scripts": {"start": "node server.js"},\
  "dependencies": {"express": "^4.18.2"}\
}' > package.json

# 创建最简单的server.js文件
RUN echo 'const express = require("express");\
const app = express();\
app.get("/", (req, res) => res.send("✅ Low-Resource Server OK"));\
app.listen(10000, "0.0.0.0", () => console.log("Low-resource server on port 10000"));' > server.js

# 仅安装express核心，跳过所有开发依赖
RUN npm install express --omit=dev --no-optional --no-audit --no-fund

EXPOSE 10000

# 启动脚本
RUN echo '#!/bin/sh\n\
/app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &\n\
echo "TraffMonetizer started in background"\n\
exec node server.js' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
