const express = require('express');
const fs = require('fs');
const app = express();
const port = process.env.PORT || 10000;

console.log('=== Server Starting ===');
console.log('TOKEN present:', !!process.env.TOKEN); // ✅ TOKEN check
console.log('TraffMonetizer logs will be shown below:');

// Main endpoint
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>TraffMonetizer Monitor</title>
      <meta http-equiv="refresh" content="5">
      <style>
        body { font-family: monospace; background: #0a0a0a; color: #00ff00; padding: 20px; }
        .header { color: #ffff00; border-bottom: 1px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .log-line { margin: 2px 0; white-space: pre-wrap; }
        .connected { color: #00ff00; }
        .error { color: #ff0000; }
        .info { color: #00ffff; }
        .token-status { color: ${process.env.TOKEN ? '#00ff00' : '#ff0000'}; }
      </style>
    </head>
    <body>
      <div class="header">
        <h2>🔍 TraffMonetizer Real-Time Monitor</h2>
        <p>Port: ${port} | Time: ${new Date().toLocaleTimeString()}</p>
        <p>TOKEN Status: <span class="token-status">${process.env.TOKEN ? '✅ SET' : '❌ NOT SET'}</span></p>
        <p><a href="/logs" style="color: #ffff00;">📄 View Full Logs</a> | <a href="/health" style="color: #00ffff;">❤️ Health</a></p>
      </div>
      
      <div id="logs">
        <h3>Recent Logs:</h3>
        ${getRecentLogs()}
      </div>
    </body>
    </html>
  `);
});

// Live logs endpoint
app.get('/logs', (req, res) => {
  try {
    const logs = fs.readFileSync('/app/tm-logs.log', 'utf8');
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Full Logs</title>
        <style>
          body { font-family: monospace; background: #0a0a0a; color: #00ff00; padding: 20px; white-space: pre-wrap; }
          a { color: #ffff00; }
        </style>
      </head>
      <body>
        <a href="/">← Back to Monitor</a>
        <hr>
        ${logs.replace(/\n/g, '<br>')}
      </body>
      </html>
    `);
  } catch (err) {
    res.send('No logs available yet. Wait a few seconds.');
  }
});

// Health endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'alive',
    server: 'running',
    traffmonetizer: 'active',
    token_set: !!process.env.TOKEN, // ✅ TOKEN check
    timestamp: new Date().toISOString()
  });
});

// Recent logs function
function getRecentLogs() {
  try {
    if (fs.existsSync('/app/tm-logs.log')) {
      const logs = fs.readFileSync('/app/tm-logs.log', 'utf8');
      const lines = logs.split('\n').slice(-20);
      return lines.map(line => {
        let colorClass = 'log-line';
        if (line.includes('Connected') || line.includes('True')) colorClass += ' connected';
        if (line.includes('Error') || line.includes('Failed')) colorClass += ' error';
        if (line.includes('Accepting') || line.includes('Bandwidth')) colorClass += ' info';
        return `<div class="${colorClass}">${line}</div>`;
      }).join('');
    }
  } catch (err) {}
  return 'Waiting for logs...';
}

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Log monitor started on port ${port}`);
  console.log(`✅ TOKEN status: ${process.env.TOKEN ? 'SET' : 'NOT SET'}`);
});
