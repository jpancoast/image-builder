#!/bin/sh

echo "Installing nodejs & npm"
apk add nodejs npm

echo "Node Version:"
node -v

echo "npm version:"
npm -v

#
#   SURPRISE! This seems to be causing issues with permisions or changing
#       permisions or something
#
echo "Installing n8n"
npm install n8n -g
