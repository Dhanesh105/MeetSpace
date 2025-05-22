#!/bin/bash
set -e

echo "Setting up static web page instead of Flutter build..."

# Create a directory for the static web files
mkdir -p build/web

# Copy the static web files to the build directory
cp -r static-web/* build/web/

# Create a simple web server script
cat > server.js << 'EOL'
const express = require('express');
const path = require('path');
const app = express();

app.use(express.static(path.join(__dirname, 'build/web')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

const port = process.env.PORT || 10000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOL

# Create package.json if it doesn't exist
if [ ! -f package.json ]; then
  cat > package.json << 'EOL'
{
  "name": "meetspace",
  "version": "1.0.0",
  "description": "MeetSpace Static Web App",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOL
fi

# Install Express.js for serving the app
npm install express
