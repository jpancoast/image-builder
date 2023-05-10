#!/bin/sh

apt-get update
apt-get upgrade -y

echo "Installing NodeJS & NPM"
apt install nodejs npm -y

echo "Installing n8n"
npm install n8n -g
