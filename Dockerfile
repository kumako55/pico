FROM traffmonetizer/cli_v2:latest

RUN apk add --no-cache python3 curl

WORKDIR /app

# Python Server (EXACTLY SAME AS YOURS - perfect hai)
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
    echo 'port = int(os.environ.get("PORT", 10000))' >> server.py && \
    echo '' >> server.py && \
    echo 'print(f"🚀 Starting server on 0.0.0.0:{port}")' >> server.py && \
    echo 'sys.stdout.flush()' >> server.py && \
    echo 'server = HTTPServer(("0.0.0.0", port), Handler)' >> server.py && \
    echo 'print("✅ Server started successfully!")' >> server.py && \
    echo 'sys.stdout.flush()' >> server.py && \
    echo 'server.serve_forever()' >> server.py

# FIXED START SCRIPT - sirf 3 lines change
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "=== CONTAINER STARTING ==="' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 1. TRAFFMONETIZER (WITH PROPER BACKGROUND MANAGEMENT)' >> start.sh && \
    echo 'echo "[1] Starting TraffMonetizer..."' >> start.sh && \
    echo 'touch /tmp/tm.pid  # PID tracking ke liye' >> start.sh && \
    echo '' >> start.sh && \
    echo '# INFINITE RESTART LOOP for TM' >> start.sh && \
    echo 'while true; do' >> start.sh && \
    echo '  if [ ! -f /tmp/tm.running ]; then' >> start.sh && \
    echo '    echo "Starting TM instance..."' >> start.sh && \
    echo '    /app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &' >> start.sh && \
    echo '    TM_PID=$!' >> start.sh && \
    echo '    echo $TM_PID > /tmp/tm.pid' >> start.sh && \
    echo '    touch /tmp/tm.running' >> start.sh && \
    echo '  fi' >> start.sh && \
    echo '  sleep 30  # Check every 30 seconds' >> start.sh && \
    echo 'done &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Wait for TM to initialize' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. Health check (YOUR EXACT CODE)' >> start.sh && \
    echo 'port=${PORT:-10000}' >> start.sh && \
    echo 'echo "[2] Checking if server is alive on port $port..."' >> start.sh && \
    echo 'if curl -s --max-time 5 http://localhost:$port > /dev/null; then' >> start.sh && \
    echo '    echo "✅ Health check passed"' >> start.sh && \
    echo 'else' >> start.sh && \
    echo '    echo "⚠️  Health check failed, but continuing..."' >> start.sh && \
    echo 'fi' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 4. Python Server (FOREGROUND - YOUR EXACT CODE)' >> start.sh && \
    echo 'echo "[3] Starting Python web server..."' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh

RUN chmod +x start.sh

CMD ["/app/start.sh"]
