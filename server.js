const express = require('express');
const { exec, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 4000;
// ✅ TOKEN use karein (TM_TOKEN ki jagah)
const TOKEN = process.env.TOKEN || 'YOUR_TOKEN_HERE';

// TM setup function
async function setupTrafficMonetizer() {
  console.log('🚀 Setting up Traffic Monetizer...');
  
  try {
    // Binary download
    console.log('📥 Downloading CLI...');
    exec(`curl -L "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN" -o /tmp/tm-cli`, (error) => {
      if (error) {
        exec(`wget -O /tmp/tm-cli "https://drive.google.com/uc?export=download&id=1P0TwYtL3ZmW1Qrmu1rSXjE0k3S7WVzHN"`);
      }
    });
    
    // Make executable
    exec('chmod +x /tmp/tm-cli');
    
    // Start worker - ✅ TOKEN variable use karein
    console.log('▶️ Starting worker with token:', TOKEN.substring(0, 10) + '...');
    const tmProcess = spawn('/tmp/tm-cli', ['start', 'accept', '--token', TOKEN], {
      detached: true,
      stdio: 'pipe'
    });
    
    // Client ID capture
    tmProcess.stdout.on('data', (data) => {
      const output = data.toString();
      console.log('TM Output:', output);
      
      const idMatch = output.match(/Client ID: ([a-zA-Z0-9-]+)/i);
      if (idMatch) {
        console.log(`✅ Client ID: ${idMatch[1]}`);
      }
    });
    
    tmProcess.unref();
    
  } catch (error) {
    console.log('❌ Setup Error:', error.message);
  }
}

// Routes
app.get('/', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: Arial; padding: 20px;">
        <h1>🚀 Traffic Monetizer Server</h1>
        <p><strong>Status:</strong> ✅ Running</p>
        <p><strong>Port:</strong> ${port}</p>
        <p><strong>Token Configured:</strong> ${TOKEN ? 'Yes' : 'No'}</p>
        <p>Check console logs for Client ID</p>
      </body>
    </html>
  `);
});

// ✅ CRITICAL: Render requires 0.0.0.0
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Server listening on port ${port} (0.0.0.0)`);
  
  // Start TM
  setupTrafficMonetizer();
  
  // Health check
  setInterval(() => {
    console.log(`[${new Date().toLocaleTimeString()}] ✅ Alive`);
  }, 30000);
});
