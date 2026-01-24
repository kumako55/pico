const express = require('express')
const app = express()
const port = process.env.PORT || 10000

app.get('/', (req, res) => {
  res.send('TraffiMonetizer is Running!')
})

app.listen(port, '0.0.0.0', () => {
  console.log(`Server listening on port ${port}`)
})
