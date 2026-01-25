FROM traffmonetizer/cli_v2:latest

# Node.js install karein
RUN apk add --no-cache nodejs npm

WORKDIR /app

# Server files copy karein
COPY package.json index.js ./

# Dependencies install karein
RUN npm install --omit=dev

EXPOSE 10000

# ✅ TOKEN variable use karein (TM_TOKEN ki jaga)
CMD ["sh", "-c", "/app/cli start accept --token $TOKEN 2>&1 | tee -a /app/tm-logs.log & exec node index.js"]
