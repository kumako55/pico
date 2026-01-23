const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('🚀 Server Alive with TraffMonetizer\n✅ Container Running\n');
}).listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log('TraffMonetizer container is active');
  
  // Just log every 30 seconds (docker ps won't work on Render)
  setInterval(() => {
    console.log(`[${new Date().toISOString()}] ✅ Status: OK`);
  }, 30000);
});
