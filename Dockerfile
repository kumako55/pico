# Stage 1: Official TraffiMonetizer image se files nikalne ke liye
FROM traffmonetizer/cli_v2:latest AS tm-source

# Stage 2: Aapki main Node Alpine image
FROM node:18-alpine

# TraffiMonetizer ko Alpine par chalne ke liye ye libraries zaroori hain
RUN apk add --no-cache gcompat libc6-compat

WORKDIR /app

# Express app ki files copy aur install karein
COPY package*.json ./
RUN npm install
COPY server.js .

# Step 4: Official image se 'tm-cli' aur zaroori files copy karein
# Note: Hum poora /app folder ya specific binary copy kar sakte hain
COPY --from=tm-source /tm-cli /app/tm-cli
RUN chmod +x /app/tm-cli

# Port 10000 for Render
EXPOSE 10000

# Step 5: Start Command
# TM background mein aur Node (Express) foreground mein
CMD ./tm-cli start accept --token "$TOKEN" & node server.js
