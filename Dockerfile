# ---------- STAGE 1: Original TraffMonetizer Environment ----------
# Yahan se binary aur uska POORA environment (libraries, config) lein ge
FROM traffmonetizer/cli_v2:latest AS tm-builder

# Pehle stage ka internal environment explore karein (optional, for debugging)
RUN find / -name "*.so*" | grep -E "(stdc++|icu|gcompat)" | head -5

# ---------- STAGE 2: Our Node.js Environment ----------
# Final image jo deploy hogi
FROM node:18-alpine

# IMPORTANT: Pehle stage se PURE binary copy nahi, uske POORE library environment ko bhi lein
# TraffMonetizer ki image ki libraries ko humare Alpine mein copy karein
COPY --from=tm-builder /lib/ /lib/
COPY --from=tm-builder /usr/lib/ /usr/lib/

# Verify karein ke libraries aa gayi hain
RUN ls -la /usr/lib/libstdc++* 2>/dev/null || echo "Checking libstdc++"

# Alpine ke liye basic compatibility (agar kuch missing ho)
RUN apk add --no-cache gcompat libstdc++ icu-libs

# TraffMonetizer ki original binary ko uske saath wali libraries ke saath copy karein
COPY --from=tm-builder /app/cli /app/traffmonetizer-cli
RUN chmod +x /app/traffmonetizer-cli

WORKDIR /app
COPY package.json index.js ./
RUN npm install --omit=dev

EXPOSE 10000

# FINAL COMMAND: Original binary ko original jaisa hi use karein
CMD ["sh", "-c", "/app/traffmonetizer-cli start accept --token $TOKEN & exec node index.js"]
