FROM traffmonetizer/cli_v2:latest

# Install Node.js and a process manager
RUN apk add --no-cache nodejs npm

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# --- CRITICAL PART STARTS ---
# 1. Aik startup script banayein
RUN echo '#!/bin/sh\n\
# Start TraffMonetizer in background\n\
/app/cli start accept --token "$TOKEN" > /tmp/tm.log 2>&1 &\n\
TM_PID=$!\n\
echo "TraffMonetizer started with PID: $TM_PID"\n\
\n\
# Start Express server in foreground\n\
echo "Starting Express server..."\n\
exec node index.js\n\
\n\
# Agar kabhi exit ho, to background process ko bhi khatam karein\ntrap "kill $TM_PID 2>/dev/null; exit" INT TERM' > /app/start.sh

RUN chmod +x /app/start.sh

# 2. Seedha start.sh ko chalaayein
CMD ["/app/start.sh"]
# --- CRITICAL PART ENDS ---
