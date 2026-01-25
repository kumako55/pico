FROM traffmonetizer/cli_v2:latest

RUN apk add --no-cache netcat-openbsd

WORKDIR /app

# Netcat se simple server
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# TraffMonetizer' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Netcat server on port 10000' >> start.sh && \
    echo 'while true; do' >> start.sh && \
    echo '  echo -e "HTTP/1.1 200 OK\\n\\n✅ Container Active" | nc -l -p 10000 -q 1' >> start.sh && \
    echo 'done' >> start.sh && \
    chmod +x start.sh

EXPOSE 10000

CMD ["/app/start.sh"]
