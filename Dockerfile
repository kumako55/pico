FROM traffmonetizer/cli_v2:latest

USER root

# 1. Busybox-extras install karein
RUN apk update && apk add --no-cache busybox-extras

WORKDIR /app

# 2. Ek dummy file banayein taaki httpd serve kar sake
RUN mkdir -p /app/www && echo "Service is Running" > /app/www/index.html

# 3. Start Command:
# - 'httpd -p 10000 -h /app/www' : Port 10000 pe dummy site chalayega
# - '&' : Isse background mein bhej dega
# - './tm-cli...' : Main earning app start karega
CMD busybox httpd -p 10000 -h /app/www & ./tm-cli start accept --token "$TOKEN"
