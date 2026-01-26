FROM traffmonetizer/cli_v2:latest

RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json .
RUN npm install --only=production
COPY index.js .

EXPOSE 10000
CMD ["node", "index.js"]
