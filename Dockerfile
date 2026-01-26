FROM traffmonetizer/cli_v2:latest

RUN apk add --no-cache python3

WORKDIR /app

# ULTRA SIMPLE PYTHON SERVER - 6 lines only
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler as H' > server.py && \
    echo 'import os' >> server.py && \
    echo 'class Handler(H):' >> server.py && \
    echo '    def do_GET(s): s.send_response(200); s.end_headers(); s.wfile.write(b"OK")' >> server.py && \
    echo 'port=int(os.getenv("PORT",10000))' >> server.py && \
    echo 'HTTPServer(("0.0.0.0",port), Handler).serve_forever()' >> server.py

# SIMPLE START SCRIPT
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# 1. TraffMonetizer' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Python Server (IMMEDIATELY)' >> start.sh && \
    echo 'exec python3 server.py' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
