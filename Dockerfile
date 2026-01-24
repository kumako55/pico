FROM traffmonetizer/cli_v2:latest

USER root

# 1. Busybox-extras install karein
RUN apk update && apk add --no-cache busybox-extras

WORKDIR /app

# 2. Render ke liye static file directory setup karein
RUN mkdir -p /app/www && echo "Earning active on Render!" > /app/www/index.html

# 3. Render default port 10000 use karta hai
ENV PORT=10000
EXPOSE 10000

# 4. Start Command:
# Isme hum 'httpd' ko foreground (-f) mein chalayenge aur 
# TraffiMonetizer ko background (&) mein.
CMD ./tm-cli start accept --token "$TOKEN" & busybox httpd -f -p 10000 -h /app/www
