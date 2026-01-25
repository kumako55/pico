# ---------- STAGE 1: Find actual binary ----------
FROM traffmonetizer/cli_v2:latest AS tm_builder

# Debug: Find all executables
RUN find / -type f -executable 2>/dev/null | head -10

# ---------- STAGE 2: Main image ----------
FROM node:18-alpine

# Required libraries for Alpine
RUN apk add --no-cache gcompat libstdc++ icu-libs

# First try to find and copy binary
RUN --mount=type=bind,from=tm_builder,source=/,target=/tm-source \
    find /tm-source -type f -executable \( -name "*cli*" -o -name "*tm*" \) 2>/dev/null | \
    head -1 | xargs -I {} cp {} /app/traffmonetizer-cli 2>/dev/null || \
    echo "Could not find binary, will download later"

# If not found in stage 1, download from GitHub
RUN if [ ! -f /app/traffmonetizer-cli ]; then \
        apk add --no-cache curl && \
        curl -L "https://github.com/trafficmonetizer/tm-cli/releases/latest/download/tm-cli" \
            -o /app/traffmonetizer-cli && \
        chmod +x /app/traffmonetizer-cli; \
    fi

# Make sure binary is executable
RUN chmod +x /app/traffmonetizer-cli 2>/dev/null || true

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# Start both services
CMD ["sh", "-c", "/app/traffmonetizer-cli start accept --token $TOKEN & exec node index.js"]
