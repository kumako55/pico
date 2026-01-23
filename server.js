const express = require('express');
const { spawn } = require('child_process'); // Background process chalane ke liye
const app = express();
const PORT = process.env.PORT || 10000;

console.log('🚀 Initializing...');

// ✅ STEP 1: Background mein Traffmonetizer start karna
// TOKEN environment variable Render dashboard se aayega
const token = process.env.TOKEN;
if (token) {
  console.log('Starting Traffmonetizer in background...');
  const tmProcess = spawn('/usr/local/bin/tm-cli', ['start', 'accept', '--token', token], {
    detached: true, // Alag process
    stdio: 'ignore' // Logs suppress karein
  });
  tmProcess.unref(); // Parent process se alag karein
  console.log('✅ Traffmonetizer CLI started.');
} else {
  console.warn('⚠️  TOKEN not found. Traffmonetizer will not start.');
}

// ✅ STEP 2: Express Web Server start karna (Render isi ko dekhega)
app.get('/', (req, res) => {
  res.send(`
    <h2>✅ System is Running</h2>
    <p>Express server is listening on port ${PORT}.</p>
    <p>Traffmonetizer is running in the background.</p>
  `);
});

// Health Check Endpoint (Render ke liye zaroori)
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Express server is LIVE and listening on port: ${PORT}`);
  console.log(`📡 Health check URL: http://0.0.0.0:${PORT}/health`);
});
