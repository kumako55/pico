const express = require('express');
const app = express();
const port = process.env.PORT || 10000;

app.get('/', (req, res) => {
  res.send('🚀 TrafficMonetizer + Express Running Successfully!<br>Both services are active.');
});

app.get('/health', (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    services: ['express', 'tm-cli'],
    node_version: process.version,
    platform: process.platform
  };
  res.status(200).json(health);
});

app.get('/logs', (req, res) => {
  res.send('Check Docker logs for tm-cli output');
});

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Express server running on port ${port}`);
  console.log(`📅 Server started: ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Express server closed');
    process.exit(0);
  });
});
