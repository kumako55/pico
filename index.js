const express = require('express');
const app = express();
const http = require('http');

console.log('=== TRYING MULTIPLE PORTS ===');
console.log('Render PORT env:', process.env.PORT);

// Try these ports one by one
const portsToTry = [10000, 8080, 3000, 5000, 7860, 80, 443];

// Create server instance
const server = http.createServer(app);

// Basic route
app.get('/', (req, res) => {
  res.send(`
    <h1>✅ Server Running</h1>
    <p>Port: ${server.address().port}</p>
    <p>All ports tried: ${portsToTry.join(', ')}</p>
  `);
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    port: server.address().port,
    listening: server.listening 
  });
});

// Function to try listening on a port
function tryPort(portIndex) {
  if (portIndex >= portsToTry.length) {
    console.error('❌ All ports failed!');
    return;
  }
  
  const port = portsToTry[portIndex];
  
  server.listen(port, '0.0.0.0')
    .on('listening', () => {
      console.log(`✅✅✅ SUCCESS: Listening on port ${port}`);
      console.log(`✅✅✅ Server URL: http://0.0.0.0:${port}`);
    })
    .on('error', (err) => {
      console.log(`❌ Port ${port} failed: ${err.code}`);
      server.close(() => {
        tryPort(portIndex + 1); // Try next port
      });
    });
}

// Start trying ports
tryPort(0);

// Also try Render's provided PORT
if (process.env.PORT && !portsToTry.includes(parseInt(process.env.PORT))) {
  console.log('Also trying Render PORT:', process.env.PORT);
  const renderPort = parseInt(process.env.PORT);
  
  const renderServer = http.createServer(app);
  renderServer.listen(renderPort, '0.0.0.0', () => {
    console.log(`✅ Also listening on Render port ${renderPort}`);
  });
        }
