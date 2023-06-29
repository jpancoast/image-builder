#!/bin/sh

echo "APP_VERSION: ${APP_VERSION}"
echo "ARCH: ${ARCH}"

cd /tmp/
wget https://releases.hashicorp.com/consul/${APP_VERSION}/consul_${APP_VERSION}_linux_${ARCH}.zip

unzip consul_${APP_VERSION}_linux_${ARCH}.zip

mv consul /usr/sbin/consul
