const express = require('express');
const { execSync } = require('child_process'); // execSync use karein
const app = express();
const PORT = process.env.PORT || 10000;

console.log('🚀 Testing Traffmonetizer Connection...');

let tmOutput = 'No output';
try {
  // tm-cli ko seedha run karein aur uska output capture karein
  tmOutput = execSync(`/usr/local/bin/tm-cli start accept --token ${process.env.TOKEN}`, {
    timeout: 10000 // 10 seconds ke baad ruk jaaye
  }).toString();
  console.log('✅ tm-cli Output:', tmOutput);
} catch (error) {
  console.error('❌ tm-cli ERROR:', error.message);
  if (error.stdout) console.error('STDOUT:', error.stdout.toString());
  if (error.stderr) console.error('STDERR:', error.stderr.toString());
}

// Express server (basic)
app.get('/', (req, res) => {
  res.send(`<pre>Test Output: ${tmOutput}</pre>`);
});
app.listen(PORT, '0.0.0.0', () => console.log(`Server on ${PORT}`));
