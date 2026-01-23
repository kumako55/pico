const express = require('express');
const app = express();
const port = process.env.PORT || 4000; // Render apna PORT set karta hai

app.get('/', (req, res) => {
  res.send('Hello World from Render!');
});

app.listen(port, () => {
  console.log(`App is running on port ${port}`);
});
