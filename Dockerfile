FROM docker.io/traffmonetizer/cli_v2:latest

ARG TOKEN
ENV TOKEN=${TOKEN}

USER root
WORKDIR /app

# Ensure python exists, then run both
CMD /bin/sh -c "\
./Cli start accept --token $TOKEN & \
python3 -m http.server 0.0.0.0:${PORT:-10000}"
