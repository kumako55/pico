# We use the original image directly to avoid path issues
FROM traffmonetizer/cli_v2:latest

# We need a shell to run our background loop
USER root

# This installs a tiny web server (busybox is much lighter than python/bash)
RUN apk update && apk add busybox-extras

# We use a single-line CMD to avoid script execution issues
# 1. Starts a tiny web server on port 10000 (Render's requirement)
# 2. Runs the TraffiMonetizer CLI
CMD httpd -p 10000 & ./tm-cli start accept --token "$TOKEN"
