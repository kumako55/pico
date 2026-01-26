FROM traffmonetizer/cli_v2:latest

# 1. APK REPOSITORY FIX - Use fast mirrors
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories

# 2. System packages with retry
RUN apk update --no-cache && \
    apk add --no-cache --virtual .build-deps \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    linux-headers \
    libffi-dev \
    openssl-dev

WORKDIR /app

# 3. PIP INSTALL with timeout and retry
RUN python3 -m pip install --upgrade pip --timeout 100 && \
    pip3 install --no-cache-dir --timeout 100 flask==2.3.3 && \
    pip3 install --no-cache-dir --timeout 100 gunicorn==20.1.0

# 4. Clean build dependencies (optional)
RUN apk del .build-deps && \
    apk add --no-cache python3

# 5. Flask app
RUN echo 'from flask import Flask' > app.py && \
    echo 'import os' >> app.py && \
    echo '' >> app.py && \
    echo 'app = Flask(__name__)' >> app.py && \
    echo '' >> app.py && \
    echo '@app.route("/")' >> app.py && \
    echo 'def home():' >> app.py && \
    echo '    return "✅ Flask Server Running"' >> app.py && \
    echo '' >> app.py && \
    echo 'if __name__ == "__main__":' >> app.py && \
    echo '    port = int(os.environ.get("PORT", 10000))' >> app.py && \
    echo '    app.run(host="0.0.0.0", port=port)' >> app.py

# 6. Start script
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo 'echo "Starting Flask..."' >> start.sh && \
    echo 'PORT=${PORT:-10000}' >> start.sh && \
    echo 'exec python3 -m gunicorn --bind 0.0.0.0:$PORT --workers 1 app:app' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
