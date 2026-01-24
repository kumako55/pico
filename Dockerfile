FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o tm-cli && chmod +x tm-cli

CMD ["./tm-cli", "start", "accept", "--token", "$TM_TOKEN"]
