const express = require('express');
const app = express();
const port = process.env.PORT || 10000;

app.get('/', (req, res) => {
  res.send('TrafficMonetizer + Express Running! TOKEN: ' + (process.env.TOKEN ? 'Set' : 'Not Set'));
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok',
    express: 'running',
    token_set: !!process.env.TOKEN,
    port: port
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server started on port ${port}`);
});
