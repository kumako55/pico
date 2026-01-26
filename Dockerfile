FROM traffmonetizer/cli_v2:latest

# 1. Pehle system packages update aur install
RUN apk update && apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    gcc \
    musl-dev \
    linux-headers \
    libffi-dev

WORKDIR /app

# 2. PYTHONPATH set karein (important for Alpine)
ENV PYTHONPATH=/usr/lib/python3.11/site-packages

# 3. Requirements.txt create karein (agar nahi hai to)
RUN echo 'flask==2.3.3' > requirements.txt && \
    echo 'gunicorn==20.1.0' >> requirements.txt

# 4. Python packages install (WITH upgraded pip)
RUN python3 -m pip install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# 5. Flask app create karein (agar app.py nahi hai)
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

# 6. Start script create karein
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo 'echo "Starting Flask..."' >> start.sh && \
    echo 'PORT=${PORT:-10000}' >> start.sh && \
    echo 'gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 2 app:app' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
