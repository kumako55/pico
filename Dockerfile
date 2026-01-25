FROM node:18-alpine
WORKDIR /app

# Sirf Express aur aapka index.js copy karein
COPY package.json index.js ./

# Install karein
RUN npm install --omit=dev

EXPOSE 10000

# Sirf Express start karein
CMD ["node", "index.js"]
