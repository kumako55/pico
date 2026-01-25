FROM traffmonetizer/cli_v2:latest
RUN apk add --no-cache python3
WORKDIR /app

# 创建并运行一个极简的Python HTTP服务器
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler\n\
import os\n\
\n\
class Handler(BaseHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.send_header("Content-type", "text/plain")\n\
        self.end_headers()\n\
        self.wfile.write(b"✅ Server Alive on Low RAM/CPU")\n\
    def log_message(self, format, *args):\n\
        pass\n\
\n\
port = 10000\n\
server = HTTPServer(("0.0.0.0", port), Handler)\n\
print(f"Minimal server starting on port {port}")\n\
server.serve_forever()' > /app/server.py

EXPOSE 10000

# 启动脚本
RUN echo '#!/bin/sh\n\
/app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &\n\
echo "TraffMonetizer started in background"\n\
exec python3 /app/server.py' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
