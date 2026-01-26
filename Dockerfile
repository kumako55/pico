FROM traffmonetizer/cli_v2:latest

# Python install with specific version
RUN apk add --no-cache python3

WORKDIR /app

# SIMPLE SERVER THAT GUARANTEED WORKS
RUN echo 'import os' > server.py && \
    echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' >> server.py && \
    echo '' >> server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"OK")' >> server.py && \
    echo '' >> server.py && \
    echo '    # DISABLE LOGS COMPLETELY' >> server.py && \
    echo '    def log_message(self, *args):' >> server.py && \
    echo '        pass' >> server.py && \
    echo '' >> server.py && \
    echo '# Get port from Render or use 10000' >> server.py && \
    echo 'PORT = int(os.environ.get("PORT", 10000))' >> server.py && \
    echo '' >> server.py && \
    echo '# CRITICAL: Must bind to 0.0.0.0, NOT 127.0.0.1' >> server.py && \
    echo 'print(f"Starting server on 0.0.0.0:{PORT}")' >> server.py && \
    echo 'httpd = HTTPServer(("0.0.0.0", PORT), Handler)' >> server.py && \
    echo 'print("Server started successfully!")' >> server.py && \
    echo 'httpd.serve_forever()' >> server.py

# SIMPLE START SCRIPT - NO COMPLEX LOGIC
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# 1. Start TraffMonetizer in background' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Start Python server in FOREGROUND' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

# IMPORTANT FOR RENDER
EXPOSE 10000

CMD ["/app/start.sh"]
