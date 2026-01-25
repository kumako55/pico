FROM traffmonetizer/cli_v2:latest

# Python install karein
RUN apk add --no-cache python3

WORKDIR /app

# Server code ko thora change karein
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler' > server.py && \
    echo 'import time' >> server.py && \
    echo '' >> server.py && \
    echo 'class Handler(BaseHTTPRequestHandler):' >> server.py && \
    echo '    def do_GET(self):' >> server.py && \
    echo '        self.send_response(200)' >> server.py && \
    echo '        self.send_header("Content-type", "text/plain")' >> server.py && \
    echo '        self.end_headers()' >> server.py && \
    echo '        self.wfile.write(b"✅ Server chal raha hai")' >> server.py && \
    echo '' >> server.py && \
    echo '    def log_message(self, format, *args):' >> server.py && \
    echo '        pass  # Logs band karein' >> server.py && \
    echo '' >> server.py && \
    echo 'print("Server 0.0.0.0:10000 par start ho raha hai...")' >> server.py && \
    echo 'httpd = HTTPServer(("0.0.0.0", 10000), Handler)' >> server.py && \
    echo 'print("✅ Server chal gaya!")' >> server.py && \
    echo 'httpd.serve_forever()' >> server.py

EXPOSE 10000

# Start script ko improve karein
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# TraffMonetizer ko background mein chalao' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo 'echo "TraffMonetizer shuru ho gaya"' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Thora wait karein (5 seconds)' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Ab Python server chalao' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
