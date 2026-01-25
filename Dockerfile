# Use traffmonetizer image as base
FROM traffmonetizer/cli_v2:latest

# Install Node.js INSIDE traffmonetizer image
RUN apk add --no-cache nodejs npm

WORKDIR /app

# Copy Express server files
COPY package.json index.js ./

# Install Express
RUN npm install --omit=dev

EXPOSE 10000 
EXPOSE 5000
EXPOSE 3000
EXPOSE 8080
EXPOSE 80
EXPOSE 443
EXPOSE 7860

# Start both services
# /app/cli is already in the traffmonetizer image
CMD ["sh", "-c", "/app/cli start accept --token $TOKEN & exec node index.js"]
