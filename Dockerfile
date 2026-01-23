FROM docker.io/traffmonetizer/cli_v2:latest

ARG TOKEN
ENV TOKEN=${TOKEN}

USER root
WORKDIR /app

# Python usually available hota hai, is se fake web server chalaenge
CMD /bin/sh -c "\
./Cli start accept --token $TOKEN & \
python3 -m http.server ${PORT:-10000}"
