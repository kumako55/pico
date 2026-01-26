const express = require('express');
const { spawn } = require('child_process');

const app = express();
const port = process.env.PORT || 10000;
const token = process.env.TOKEN;

if (!token) {
  console.error('ERROR: TOKEN environment variable not set!');
  process.exit(1);
}

// Spawn the official TraffMonetizer CLI
const tm = spawn('tmcli', ['start', 'accept', '--token', token]);

// Log TM stdout and stderr
tm.stdout.on('data', data => console.log('[TM]', data.toString().trim()));
tm.stderr.on('data', data => console.error('[TM ERR]', data.toString().trim()));

tm.on('close', code => console.log(`[TM] TraffMonetizer exited with code ${code}`));
tm.on('error', err => console.error('[TM ERR]', `Failed to start: ${err.message}`));

// Express server to keep container alive and optionally show status
app.get('/', (req, res) => {
  res.send('<pre>TraffMonetizer running...\nCheck logs for details</pre>');
});

app.listen(port, () => console.log(`Express server listening on port ${port}`));
