FROM traffmonetizer/cli_v2:latest

# Install Node.js for the web server
RUN apk add --no-cache nodejs npm

# Create app directory
WORKDIR /app

# Copy server file
COPY server.js .

# Set environment variables
ENV TOKEN=your_token_here
ENV PORT=3000

# Run both: TraffMonetizer + Node.js server
CMD sh -c "start accept --token ${TOKEN} & node server.js"
