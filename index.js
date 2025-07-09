const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Node.js on AKS with Helm and GitHub Actions!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
