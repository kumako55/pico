const http = require("http");
const port = process.env.PORT || 10000;

http.createServer((req, res) => {
  res.writeHead(200);
  res.end("TraffMonetizer active");
}).listen(port, "0.0.0.0", () => {
  console.log("Listening on port", port);
});
