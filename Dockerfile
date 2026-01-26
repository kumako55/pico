FROM traffmonetizer/cli_v2:latest

# Only install bash (Python ki zaroorat nahi)
RUN apk add --no-cache bash ncurses

WORKDIR /app

# SIMPLE BASH HTTP SERVER
RUN echo '#!/bin/bash' > server.sh && \
    echo '' >> server.sh && \
    echo 'PORT=${PORT:-10000}' >> server.sh && \
    echo 'echo "Server starting on port $PORT"' >> server.sh && \
    echo '' >> server.sh && \
    echo 'while true; do' >> server.sh && \
    echo '  # Simple HTTP response' >> server.sh && \
    echo '  RESPONSE="HTTP/1.1 200 OK\r\nContent-Length: 21\r\n\r\n✅ Server Active OK"' >> server.sh && \
    echo '  echo -e "$RESPONSE" | nc -l -p $PORT -q 1 -s 0.0.0.0' >> server.sh && \
    echo '  echo "Request served at $(date)"' >> server.sh && \
    echo 'done' >> server.sh && \
    chmod +x server.sh

# MAIN START SCRIPT
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "=== CONTAINER STARTED ==="' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 1. Start TraffMonetizer' >> start.sh && \
    echo 'echo "Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Wait 3 seconds' >> start.sh && \
    echo 'sleep 3' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. Start HTTP Server' >> start.sh && \
    echo 'exec /app/server.sh' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
