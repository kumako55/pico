FROM traffmonetizer/cli_v2:latest

# Install Node.js
RUN apk add --no-cache nodejs npm

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# --- CRITICAL FIX: Create start.sh properly ---
# Pehle script ki file banayein aur phir chmod karein
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &' >> /app/start.sh && \
    echo 'TM_PID=$!' >> /app/start.sh && \
    echo 'echo "TraffMonetizer started with PID: $TM_PID"' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'echo "Starting Express server..."' >> /app/start.sh && \
    echo 'exec node index.js' >> /app/start.sh

# Script ko executable banayein
RUN chmod +x /app/start.sh

# Start script run karein
CMD ["/app/start.sh"]
