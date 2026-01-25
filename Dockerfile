FROM node:18-alpine
WORKDIR /app
RUN echo 'console.log("Test: Node works")' > index.js
CMD ["node", "index.js"]
