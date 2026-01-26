const http = require('http');

http.createServer((req, res) => {
  res.writeHead(200);
  res.end('TraffMonetizer running');
}).listen(10000, () => {
  console.log('Listening on port 10000');
});

// Start tmcli in background
const { spawn } = require('child_process');
spawn('/usr/local/bin/tmcli', ['start', 'accept', '--token', process.env.TOKEN], { stdio: 'inherit' });
