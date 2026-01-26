const express = require("express");
const { spawn } = require("child_process");

const app = express();
const port = process.env.PORT || 10000;
const token = process.env.TOKEN;

if (!token) {
  console.error("TOKEN missing");
  process.exit(1);
}

// OFFICIAL tmcli path (image ke andar)
const tm = spawn("tmcli", ["start", "accept", "--token", token]);

tm.stdout.on("data", d => console.log("[TM]", d.toString()));
tm.stderr.on("data", d => console.error("[TM ERR]", d.toString()));
tm.on("close", c => console.log("TM exited:", c));

// Simple keep-alive endpoint
app.get("/", (_, res) => res.send("TraffMonetizer running"));

app.listen(port, "0.0.0.0", () =>
  console.log("Server listening on", port)
);
