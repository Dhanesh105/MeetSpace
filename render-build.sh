#!/bin/bash
set -e

# Download and install Flutter
echo "Downloading Flutter..."
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.5-stable.tar.xz
echo "Extracting Flutter..."
tar xf flutter_linux_2.10.5-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable web
flutter config --enable-web

# Build the web app
echo "Building Flutter web app..."
flutter build web --release

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
  "description": "MeetSpace Flutter Web App",
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
