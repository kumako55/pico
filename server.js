const express = require('express');
const { execSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const app = express();
const PORT = process.env.PORT || 10000;

// ========================
// 1. COMPLETE DIAGNOSTICS
// ========================
console.log('🔍 ===== STARTING DIAGNOSTICS =====');

// 1.1 System Architecture Check
console.log(`[1] System: ${os.platform()}, Architecture: ${os.arch()}`);

// 1.2 TOKEN Check
const token = process.env.TOKEN;
console.log(`[2] TOKEN exists? ${!!token}`);
if (token) {
  // Show first 5 chars for verification (don't log full token for security)
  console.log(`    Token Preview: ${token.substring(0, 5)}...`);
}

// 1.3 Binary Check with PERMISSIONS
const binaryPath = '/usr/local/bin/tm-cli';
console.log(`[3] Checking Binary: ${binaryPath}`);

try {
  // Check if file exists
  if (!fs.existsSync(binaryPath)) {
    console.log('    ❌ ERROR: Binary file does NOT exist!');
  } else {
    console.log('    ✅ Binary file exists.');
    
    // Check file permissions (like ls -la)
    const stats = fs.statSync(binaryPath);
    const mode = stats.mode.toString(8); // Convert to octal (like 755)
    console.log(`    File Mode (Permissions): ${mode}`);
    
    // Check if executable (using fs.accessSync)
    try {
      fs.accessSync(binaryPath, fs.constants.X_OK);
      console.log('    ✅ Binary is EXECUTABLE.');
      
      // Get file type info using 'file' command
      try {
        const fileInfo = execSync(`file ${binaryPath}`).toString().trim();
        console.log(`    File Type: ${fileInfo}`);
      } catch (fileErr) {
        console.log(`    ⚠️  Could not determine file type: ${fileErr.message}`);
      }
    } catch (accessErr) {
      console.log(`    ❌ Binary is NOT executable: ${accessErr.message}`);
      console.log('    Trying to fix permissions with chmod +x...');
      try {
        execSync(`chmod +x ${binaryPath}`);
        console.log('    ✅ Permissions fixed (chmod +x executed).');
      } catch (chmodErr) {
        console.log(`    ❌ Failed to fix permissions: ${chmodErr.message}`);
      }
    }
  }
} catch (err) {
  console.log(`    ❌ Error checking binary: ${err.message}`);
}

// ========================
// 2. RUN TRAFFMONETIZER CLI
// ========================
console.log('\n🚀 ===== RUNNING TRAFFMONETIZER =====');
let commandOutput = 'No command was executed.';
let finalStatus = 'Unknown';

if (token) {
  try {
    console.log(`[4] Executing command: tm-cli start accept --token [HIDDEN]`);
    
    // Run the command with timeout
    commandOutput = execSync(
      `/usr/local/bin/tm-cli start accept --token ${token}`,
      { 
        timeout: 30000, // 30 seconds timeout
        encoding: 'utf-8',
        stdio: ['pipe', 'pipe', 'pipe'] // Capture stdout AND stderr
      }
    ).toString();
    
    console.log('✅ tm-cli command executed SUCCESSFULLY.');
    console.log(`📋 Command Output:\n${commandOutput}`);
    finalStatus = 'Success';
    
  } catch (error) {
    console.error('❌ tm-cli command FAILED!');
    finalStatus = `Failed: ${error.message}`;
    
    // Capture ALL possible output
    let fullError = `Error: ${error.message}\n`;
    if (error.stdout) {
      console.error('STDOUT:', error.stdout.toString());
      fullError += `STDOUT: ${error.stdout.toString()}\n`;
    }
    if (error.stderr) {
      console.error('STDERR:', error.stderr.toString());
      fullError += `STDERR: ${error.stderr.toString()}\n`;
    }
    
    commandOutput = fullError;
    console.log(`📋 Full Error Details:\n${commandOutput}`);
  }
} else {
  console.log('⚠️  Skipping tm-cli execution because TOKEN is not set.');
  commandOutput = 'TOKEN environment variable is missing.';
  finalStatus = 'Skipped (No Token)';
}

// ========================
// 3. EXPRESS SERVER ROUTES
// ========================
console.log('\n🌐 ===== STARTING EXPRESS SERVER =====');

// Main route - shows diagnostics
app.get('/', (req, res) => {
  const html = `
  <!DOCTYPE html>
  <html>
  <head>
    <title>TraffMonetizer Diagnostics</title>
    <style>
      body { font-family: monospace; margin: 20px; background: #f5f5f5; }
      pre { background: white; padding: 15px; border-radius: 5px; border: 1px solid #ddd; overflow-x: auto; }
      .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
      .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
      .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
      .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
    </style>
  </head>
  <body>
    <h2>🛠️ TraffMonetizer Diagnostics</h2>
    <div class="status ${finalStatus.includes('Success') ? 'success' : finalStatus.includes('Failed') ? 'error' : 'info'}">
      <strong>Final Status:</strong> ${finalStatus}
    </div>
    <h3>Command Output:</h3>
    <pre>${commandOutput}</pre>
    <hr>
    <p><small>Server running on port ${PORT}. Time: ${new Date().toLocaleString()}</small></p>
  </body>
  </html>
  `;
  res.send(html);
});

// Health check for Render
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Debug endpoint for system info
app.get('/debug', (req, res) => {
  res.json({
    system: {
      platform: os.platform(),
      architecture: os.arch(),
      cpus: os.cpus().length,
      memory: (os.totalmem() / 1024 / 1024 / 1024).toFixed(1) + ' GB'
    },
    tokenExists: !!token,
    binaryPath: binaryPath,
    binaryExists: fs.existsSync(binaryPath)
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Express server is LIVE on port: ${PORT}`);
  console.log(`📡 Health check: http://0.0.0.0:${PORT}/health`);
  console.log(`🔧 Debug info: http://0.0.0.0:${PORT}/debug`);
  console.log('\n📊 ===== DIAGNOSTICS COMPLETE =====');
});
