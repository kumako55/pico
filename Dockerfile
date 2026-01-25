FROM traffmonetizer/cli_v2:latest

# Python install karein
RUN apk add --no-cache python3

WORKDIR /app

# Server code - ab yeh wait karega TraffMonetizer ke liye
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'import time' >> server.py && \
    echo 'import socket' >> server.py && \
    echo '' >> server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Server aur TraffMonetizer dono chal rahe hain")' >> server.py && \
    echo '' >> server.py && \
    echo '    def log_message(self, format, *args):' >> server.py && \
    echo '        pass' >> server.py && \
    echo '' >> server.py && \
    echo '# Pehle TraffMonetizer ke liye wait karein' >> server.py && \
    echo 'print("TraffMonetizer ke liye wait kar raha hoon...")' >> server.py && \
    echo 'time.sleep(10)' >> server.py && \
    echo '' >> server.py && \
    echo '# Ab server start karein' >> server.py && \
    echo 'print("Server 0.0.0.0:10000 par start ho raha hai...")' >> server.py && \
    echo 'httpd = HTTPServer(("0.0.0.0", 10000), Handler)' >> server.py && \
    echo 'print("✅ Server chal gaya!")' >> server.py && \
    echo 'httpd.serve_forever()' >> server.py

EXPOSE 10000

# IMPORTANT: Yeh new start script
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# PEHLE TraffMonetizer start karein' >> start.sh && \
    echo 'echo "1. TraffMonetizer start kar raha hoon..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 10 seconds wait karein TraffMonetizer ke liye' >> start.sh && \
    echo 'echo "2. 10 seconds wait kar raha hoon..."' >> start.sh && \
    echo 'sleep 10' >> start.sh && \
    echo '' >> start.sh && \
    echo '# AB server start karein' >> start.sh && \
    echo 'echo "3. Python server start kar raha hoon..."' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
