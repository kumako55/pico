FROM traffmonetizer/cli_v2:latest

# STEP 1: Apk update zaroori hai[citation:3][citation:9]
RUN apk update

# STEP 2: Build dependencies ke saath python aur pip install karein[citation:6]
RUN apk add --no-cache python3 py3-pip gcc musl-dev linux-headers

WORKDIR /app

# Flask app ka code yahan copy ya create karein
COPY . .

# STEP 3: Flask aur Gunicorn install karein
RUN pip3 install --no-cache-dir flask gunicorn

# Baaki ka aapka start script
CMD ["/app/start.sh"]
