FROM traffmonetizer/cli_v2:latest

# Python install karein
RUN apk add --no-cache python3

WORKDIR /app

# 1. Simple Python Server (Port 10000 par)
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Server Active on Port 10000")' >> server.py && \
    echo '    def log_message(self, *args): pass' >> server.py && \
    echo '' >> server.py && \
    echo 'print("Starting Health Server on 0.0.0.0:10000")' >> server.py && \
    echo 'HTTPServer(("0.0.0.0", 10000), Handler).serve_forever()' >> server.py

EXPOSE 10000  # Sirf health server ka port expose karein

# 2. Start Script (Dono Services Ek Saath)
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# Pehle TraffMonetizer chalao (BACKGROUND)' >> start.sh && \
    echo 'echo "[1] Starting TraffMonetizer in background..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo 'sleep 10  # Thora wait karein initialize hone ke liye' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Phir Health Server chalao (FOREGROUND - Yeh woh process hai jo container chalaye gi)' >> start.sh && \
    echo 'echo "[2] Starting Health Check Server on port 10000..."' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
