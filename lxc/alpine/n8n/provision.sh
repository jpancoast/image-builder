#!/bin/sh

apk add nodejs npm

echo "Node Version:"
node -v

echo "npm version:"
npm -v

npm install n8n -g
