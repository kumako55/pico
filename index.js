const express = require('express');
const app = express();

// Render provides PORT, but we'll use 10000 for consistency
const port = 10000; // Force 10000

console.log('Render PORT env:', process.env.PORT);
console.log('Using port:', port);

app.get('/', (req, res) => {
  res.send('Server on fixed port ' + port);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`✅ Fixed port ${port} listening on 0.0.0.0`);
});
