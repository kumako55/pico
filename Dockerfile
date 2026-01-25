# ---------- STAGE 1: Find actual binary ----------
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Binary ki actual location find karein
RUN find / -type f -executable \( -name "*cli*" -o -name "*tm*" \) 2>/dev/null | head -5 > /binary_locations.txt
RUN cat /binary_locations.txt

# ---------- STAGE 2: Our Node.js Environment ----------
FROM node:18-alpine

# IMPORTANT: Libraries copy karein (selective approach)
COPY --from=tm-builder /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=tm-builder /usr/lib/libstdc++.so* /usr/lib/
COPY --from=tm-builder /usr/lib/libicu*.so* /usr/lib/

# Alpine compatibility
RUN apk add --no-cache gcompat libstdc++ icu-libs

# TraffMonetizer ki binary copy karein (try multiple possible locations)
# Try 1: Most common location
COPY --from=tm-builder /usr/bin/cli /app/traffmonetizer-cli 2>/dev/null || \
# Try 2: Another possible location  
COPY --from=tm-builder /bin/cli /app/traffmonetizer-cli 2>/dev/null || \
# Try 3: Maybe it's called tm-cli
COPY --from=tm-builder /usr/bin/tm-cli /app/traffmonetizer-cli 2>/dev/null || \
# Try 4: Check what we found in debug
RUN echo "Binary not found in common locations" && exit 1

RUN chmod +x /app/traffmonetizer-cli 2>/dev/null || echo "Binary may not exist"

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# Command - check if binary exists
CMD ["sh", "-c", "
  if [ -f /app/traffmonetizer-cli ]; then
    echo '✅ Binary found at /app/traffmonetizer-cli'
    /app/traffmonetizer-cli start accept --token $TOKEN &
  else
    echo '❌ Binary not found, checking system...'
    find / -name '*cli*' -type f -executable 2>/dev/null | head -5
  fi
  exec node index.js
"]
