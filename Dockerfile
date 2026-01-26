FROM traffmonetizer/cli_v2:latest

# 1. System packages (all in one RUN to reduce layers)
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    linux-headers

WORKDIR /app

# 2. DIRECT pip install (without requirements.txt)
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir flask==2.3.3 gunicorn==20.1.0

# 3. Create Flask app
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

# 4. Start script
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "1. Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo 'sleep 3' >> start.sh && \
    echo '' >> start.sh && \
    echo 'echo "2. Starting Flask server..."' >> start.sh && \
    echo 'PORT=${PORT:-10000}' >> start.sh && \
    echo 'exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 2 --timeout 120 app:app' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
