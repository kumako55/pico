const express = require('express');
const app = express();

// Render automatically PORT set karta hai
const port = process.env.PORT || 10000;

app.get('/', (req, res) => {
  res.send('TraffiMonetizer is Running!');
});

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
