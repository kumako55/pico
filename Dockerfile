FROM node:18-alpine

# Required libraries
RUN apk add --no-cache supervisor gcompat libstdc++ icu-libs curl

WORKDIR /app

# Download tm-cli
RUN curl -L "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o tm-cli && chmod +x tm-cli

# Copy app files
COPY package.json index.js ./

# Install dependencies
RUN npm install --production

# Create supervisord config - TOKEN variable use karein
RUN echo '[supervisord]' > /etc/supervisor.conf && \
    echo 'nodaemon=true' >> /etc/supervisor.conf && \
    echo '' >> /etc/supervisor.conf && \
    echo '[program:express]' >> /etc/supervisor.conf && \
    echo 'command=node index.js' >> /etc/supervisor.conf && \
    echo 'directory=/app' >> /etc/supervisor.conf && \
    echo 'autostart=true' >> /etc/supervisor.conf && \
    echo 'autorestart=true' >> /etc/supervisor.conf && \
    echo '' >> /etc/supervisor.conf && \
    echo '[program:tmcli]' >> /etc/supervisor.conf && \
    echo 'command=/app/tm-cli start accept --token %(ENV_TOKEN)s' >> /etc/supervisor.conf && \
    echo 'directory=/app' >> /etc/supervisor.conf && \
    echo 'autostart=true' >> /etc/supervisor.conf && \
    echo 'autorestart=true' >> /etc/supervisor.conf

EXPOSE 10000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
