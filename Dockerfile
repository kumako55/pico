# Direct Docker Hub se image fetch karne ke liye 'docker.io' prefix lagayein
FROM docker.io/traffmonetizer/cli_v2:latest

# Secret/Variable define karein
ARG TOKEN
ENV TOKEN=${TOKEN}

# Root user switch karein taake permissions ka masla na ho
USER root

# Working directory set karein
WORKDIR /app

# Final Run command
# Yahan 'sh -c' ka use isliye zaroori hai taake $TOKEN variable pick ho sake
ENTRYPOINT ["/bin/sh", "-c", "./Cli start accept --token $TOKEN"]
