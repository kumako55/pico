FROM node:18-alpine
RUN apk add --no-cache gcompat libstdc++ icu-libs curl
WORKDIR /app
RUN curl -L "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o tm-cli && chmod +x tm-cli
COPY package.json index.js start.sh ./
RUN chmod +x start.sh
RUN npm install --only=production
EXPOSE 10000
CMD ["./start.sh"]
