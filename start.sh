#!/bin/sh
# Start tm-cli in the background using the TOKEN variable
/app/tm-cli start accept --token "$TOKEN" &
# Start the Express server in the foreground
node index.js
