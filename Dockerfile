FROM traffmonetizer/cli_v2:latest

RUN apk add --no-cache python3 curl

WORKDIR /app

# Server code - same as before
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'import os' >> server.py && \
    echo '' >> server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Server Active")' >> server.py && \
    echo '' >> server.py && \
    echo 'port = int(os.environ.get("PORT", 10000))' >> server.py && \
    echo 'print(f"Server on 0.0.0.0:{port}")' >> server.py && \
    echo 'HTTPServer(("0.0.0.0", port), Handler).serve_forever()' >> server.py

# IMPORTANT: FIXED START SCRIPT
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "=== STARTING ==="' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 1. TRAFFMONETIZER - CRON KE THROUGH RESTART KARENGE' >> start.sh && \
    echo 'echo "[1] Setting up TraffMonetizer with auto-restart..."' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Every 5 minutes check if TM is running' >> start.sh && \
    echo 'echo "*/5 * * * * /app/cli start accept --token \\"\\$TOKEN\\" > /tmp/tm.log 2>&1" > /etc/crontabs/root' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Start cron daemon' >> start.sh && \
    echo 'crond' >> start.sh && \
    echo '' >> start.sh && \
    echo '# First run of TraffMonetizer' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &' >> start.sh && \
    echo 'echo "TraffMonetizer started (will auto-restart every 5 minutes)"' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. PYTHON SERVER (foreground)' >> start.sh && \
    echo 'echo "[2] Starting Python server..."' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh

RUN chmod +x start.sh

CMD ["/app/start.sh"]
