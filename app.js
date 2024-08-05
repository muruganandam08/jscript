// app.js
'use strict';

require('./tracer'); // Import the tracer configuration

const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello, OpenTelemetry!');
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
