FROM traffmonetizer/cli_v2:latest

# Flask aur dependencies install karein
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --no-cache-dir flask gunicorn

WORKDIR /app

# Flask app create karein
RUN echo 'from flask import Flask' > app.py && \
    echo 'import os' >> app.py && \
    echo '' >> app.py && \
    echo 'app = Flask(__name__)' >> app.py && \
    echo '' >> app.py && \
    echo '@app.route("/")' >> app.py && \
    echo 'def home():' >> app.py && \
    echo '    return "✅ Flask Server on Render"' >> app.py && \
    echo '' >> app.py && \
    echo '@app.route("/health")' >> app.py && \
    echo 'def health():' >> app.py && \
    echo '    return {"status": "ok", "port": os.environ.get("PORT", "10000")}' >> app.py && \
    echo '' >> app.py && \
    echo 'if __name__ == "__main__":' >> app.py && \
    echo '    port = int(os.environ.get("PORT", 10000))' >> app.py && \
    echo '    print(f"Flask starting on port {port}")' >> app.py && \
    echo '    app.run(host="0.0.0.0", port=port)' >> app.py

# Requirements file (optional but good practice)
RUN echo 'flask==2.3.3' > requirements.txt && \
    echo 'gunicorn==20.1.0' >> requirements.txt

# Start script with Gunicorn (production-ready)
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo 'echo "=== STARTING ==="' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 1. Start TraffMonetizer' >> start.sh && \
    echo 'echo "Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Wait for TM to initialize' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. Start Flask with Gunicorn (Render-friendly)' >> start.sh && \
    echo 'PORT=${PORT:-10000}' >> start.sh && \
    echo 'echo "Starting Flask on port $PORT"' >> start.sh && \
    echo 'exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 2 --timeout 60 app:app' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
