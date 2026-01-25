FROM traffmonetizer/cli_v2:latest

# 仅安装Python3，最轻量（无需npm或Node.js额外包）
RUN apk add --no-cache python3

WORKDIR /app

# 1. 创建超轻量Python HTTP服务器
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'import os' >> server.py && \
    echo '' >> server.py && \
    echo 'class SimpleHandler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Ultra-Light Server (512MB/0.1vCPU) Active")' >> server.py && \
    echo '' >> server.py && \
    echo '    # 禁用详细日志以减少CPU/IO开销' >> server.py && \
    echo '    def log_message(self, format, *args):' >> server.py && \
    echo '        pass' >> server.py && \
    echo '' >> server.py && \
    echo '# 固定端口，避免环境变量解析开销' >> server.py && \
    echo 'server = HTTPServer(("0.0.0.0", 10000), SimpleHandler)' >> server.py && \
    echo 'print("🚀 Minimal Python server ready on port 10000")' >> server.py && \
    echo 'server.serve_forever()' >> server.py

EXPOSE 10000

# 2. 优化启动脚本：分离TraffMonetizer与服务器日志
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# 将TraffMonetizer输出重定向到文件，减少终端开销' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo 'echo "TraffMonetizer: Background service started"' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 在前台运行Python服务器（唯一前台进程）' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

# 3. 设置启动命令
CMD ["/app/start.sh"]
