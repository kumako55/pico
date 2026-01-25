console.log('=== DEBUG: Server Starting ===');

const express = require('express');
const app = express();
const port = 10000; // Fixed port (remove process.env.PORT)

console.log('1. Express loaded');
console.log('2. Port set to:', port);

// Simple route
app.get('/', (req, res) => {
  console.log('GET / request received');
  res.send('✅ Server Running (Debug Mode)');
});

console.log('3. Routes configured');

// Explicit listen with error handling
try {
  const server = app.listen(port, '0.0.0.0', () => {
    console.log(`✅✅✅ SUCCESS: Server listening on 0.0.0.0:${port}`);
    console.log(`✅✅✅ Server URL: http://0.0.0.0:${port}`);
  });
  
  // Check server address
  const address = server.address();
  console.log('Server address info:', address);
  
  // Error handler for server
  server.on('error', (err) => {
    console.error('❌ Server error:', err.message);
    if (err.code === 'EADDRINUSE') {
      console.error('Port already in use!');
    }
  });
  
} catch (error) {
  console.error('❌ Failed to start server:', error);
  process.exit(1);
}

console.log('4. Server startup code executed');
