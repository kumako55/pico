# Step 1: Node Alpine image
FROM node:18-alpine

# Step 2: Zaroori tools (gcompat binary chalane ke liye lazmi hai)
RUN apk add --no-cache curl gcompat libc6-compat

WORKDIR /app

# Step 3: Express setup (Aapki files copy ho rahi hain)
COPY package*.json ./
RUN npm install
COPY index.js .

# Step 4: Google Drive se binary download karne ki special command
# Humne 'confirm' query add ki hai taaki virus warning bypass ho sake
RUN curl -L "https://docs.google.com/uc?export=download&confirm=$(curl -sL 'https://docs.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN' | grep -o 'confirm=[^&]*' | sed 's/confirm=//')&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o tm-cli && \
    chmod +x tm-cli

# Step 5: Render port exposure
EXPOSE 10000

# Step 6: Dono ko chalayein
# TraffiMonetizer background mein (&) aur Node foreground mein
CMD ./tm-cli start accept --token "$TOKEN" & node server.js
