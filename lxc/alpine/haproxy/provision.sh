#!/bin/sh

echo "APP_VERSION: ${APP_VERSION}"
echo "ARCH: ${ARCH}"

apk add haproxy
apk add haproxy-openrc

rc-update add haproxy default
