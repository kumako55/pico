FROM traffmonetizer/cli_v2:latest

# Python aur curl install karein (curl health check ke liye)
RUN apk add --no-cache python3 curl

WORKDIR /app

# 1. BILKUL SIMPLE SERVER CODE
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'import os' >> server.py && \
    echo 'import sys' >> server.py && \
    echo '' >> server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Render Server Working")' >> server.py && \
    echo '' >> server.py && \
    echo '    def log_message(self, format, *args):' >> server.py && \
    echo '        print(f"Request: {self.path}")' >> server.py && \
    echo '' >> server.py && \
    echo '# RENDER KA PORT VARIABLE USE KAREN' >> server.py && \
    echo 'port = int(os.environ.get("PORT", 10000))' >> server.py && \
    echo '' >> server.py && \
    echo '# MUST USE 0.0.0.0, NOT 127.0.0.1' >> server.py && \
    echo 'print(f"🚀 Starting server on 0.0.0.0:{port}")' >> server.py && \
    echo 'sys.stdout.flush()  # Important for Render logs' >> server.py && \
    echo 'server = HTTPServer(("0.0.0.0", port), Handler)' >> server.py && \
    echo 'print("✅ Server started successfully!")' >> server.py && \
    echo 'sys.stdout.flush()' >> server.py && \
    echo 'server.serve_forever()' >> server.py

# 2. START SCRIPT WITH PROPER LOGGING
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "=== CONTAINER STARTING ==="' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 1. PEHLE TRAFFMONETIZER (BACKGROUND)' >> start.sh && \
    echo 'echo "[1] Starting TraffMonetizer..."' >> start.sh && \
    echo 'nohup /app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &' >> start.sh && \
    echo 'echo "TraffMonetizer started in background"' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. THORA WAIT' >> start.sh && \
    echo 'sleep 3' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. HEALTH CHECK - APNA HI SERVER KO CHECK KAREN' >> start.sh && \
    echo 'port=${PORT:-10000}' >> start.sh && \
    echo 'echo "[2] Checking if server is alive on port $port..."' >> start.sh && \
    echo 'if curl -s --max-time 5 http://localhost:$port > /dev/null; then' >> start.sh && \
    echo '    echo "✅ Health check passed"' >> start.sh && \
    echo 'else' >> start.sh && \
    echo '    echo "⚠️  Health check failed, but continuing..."' >> start.sh && \
    echo 'fi' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 4. FINALLY START PYTHON SERVER (FOREGROUND)' >> start.sh && \
    echo 'echo "[3] Starting Python web server..."' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh

RUN chmod +x start.sh

CMD ["/app/start.sh"]
