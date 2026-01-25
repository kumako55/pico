# ---------- STAGE 1: Find actual binary ----------
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Binary ki actual location find karein
RUN find / -type f -executable \( -name "*cli*" -o -name "*tm*" \) 2>/dev/null | head -5

# ---------- STAGE 2: Our Node.js Environment ----------
FROM node:18-alpine

# IMPORTANT: Libraries copy karein
COPY --from=tm-builder /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=tm-builder /usr/lib/libstdc++.so* /usr/lib/ 2>/dev/null || true
COPY --from=tm-builder /usr/lib/libicu*.so* /usr/lib/ 2>/dev/null || true

# Alpine compatibility
RUN apk add --no-cache gcompat libstdc++ icu-libs

# TraffMonetizer ki binary copy karein - DEBUG FIRST
# Pehle check karein kya binary exist karti hai
RUN echo "DEBUG: Checking for binary in tm-builder..."
RUN docker run --rm traffmonetizer/cli_v2:latest find / -name "*cli*" -type f -executable 2>/dev/null || echo "Not found"

# Actually copy the binary (common locations)
COPY --from=tm-builder /app/cli /app/traffmonetizer-cli 2>/dev/null || \
COPY --from=tm-builder /usr/bin/cli /app/traffmonetizer-cli 2>/dev/null || \
COPY --from=tm-builder /usr/local/bin/cli /app/traffmonetizer-cli 2>/dev/null || \
RUN echo "Warning: Could not find binary in common locations"

# Make executable if exists
RUN test -f /app/traffmonetizer-cli && chmod +x /app/traffmonetizer-cli || echo "No binary to make executable"

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# Simple and correct CMD
CMD ["sh", "-c", "if [ -f /app/traffmonetizer-cli ]; then /app/traffmonetizer-cli start accept --token $TOKEN & fi; exec node index.js"]
