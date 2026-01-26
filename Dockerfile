FROM traffmonetizer/cli_v2:latest

# 1. System packages
RUN apk update && apk add --no-cache python3 py3-pip

WORKDIR /app

# 2. Install Flask only (no gunicorn for now)
RUN pip3 install --no-cache-dir flask==2.3.3

# 3. Flask app
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
    echo '    print(f"Starting Flask on 0.0.0.0:{port}")' >> app.py && \
    echo '    app.run(host="0.0.0.0", port=port, debug=False)' >> app.py

# 4. CORRECT START SCRIPT
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# 1. TraffMonetizer' >> start.sh && \
    echo 'echo "Starting TraffMonetizer..."' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Wait' >> start.sh && \
    echo 'sleep 3' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. Flask server - SIMPLE DIRECT WAY' >> start.sh && \
    echo 'PORT=${PORT:-10000}' >> start.sh && \
    echo 'echo "Flask port: $PORT"' >> start.sh && \
    echo 'exec python3 app.py' >> start.sh && \
    chmod +x start.sh

CMD ["/app/start.sh"]
