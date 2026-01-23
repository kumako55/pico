FROM docker.io/traffmonetizer/cli_v2:latest

ARG TOKEN
ENV TOKEN=${TOKEN}
ENV PORT=${PORT:-10000}

USER root
WORKDIR /app

# Traffmonetizer ko start karen
CMD /bin/sh -c "./Cli start accept --token $TOKEN & python3 -m http.server 0.0.0.0:${PORT}"
