FROM traffmonetizer/cli_v2:latest

# 1. Alpine Linux ke liye sahi package manager
RUN apk add --no-cache nodejs npm python3

WORKDIR /app

# 2. Node.js server create karein
RUN echo 'const express = require("express");' > index.js && \
    echo 'const app = express();' >> index.js && \
    echo '' >> index.js && \
    echo 'app.get("/", (req, res) => {' >> index.js && \
    echo '  res.send("✅ Node Server on Render");' >> index.js && \
    echo '});' >> index.js && \
    echo '' >> index.js && \
    echo 'const port = process.env.PORT || 10000;' >> index.js && \
    echo 'app.listen(port, "0.0.0.0", () => {' >> index.js && \
    echo '  console.log(`Server running on port ${port}`);' >> index.js && \
    echo '});' >> index.js

# 3. Package.json create karein
RUN echo '{' > package.json && \
    echo '  "name": "render-server",' >> package.json && \
    echo '  "version": "1.0.0",' >> package.json && \
    echo '  "dependencies": {' >> package.json && \
    echo '    "express": "^4.18.2"' >> package.json && \
    echo '  }' >> package.json && \
    echo '}' >> package.json

# 4. Install dependencies
RUN npm install --only=production

# 5. Start script with BOTH services
RUN echo '#!/bin/sh' > start.sh && \
    echo '' >> start.sh && \
    echo '# 1. Start TraffMonetizer in background' >> start.sh && \
    echo '/app/cli start accept --token "$TOKEN" > /dev/null 2>&1 &' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 2. Wait for TM to initialize' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo '' >> start.sh && \
    echo '# 3. Start Node.js server (foreground)' >> start.sh && \
    echo 'exec node index.js' >> start.sh && \
    chmod +x start.sh

EXPOSE 10000
CMD ["/app/start.sh"]
