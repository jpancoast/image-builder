#!/bin/sh

echo "search $DNS_SEARCH_DOMAIN" >/etc/resolv.conf
echo "nameserver $DNS_1" >>/etc/resolv.conf
echo "nameserver $DNS_2" >>/etc/resolv.conf

apk update
apk upgrade -v
apk add --no-cache tzdata
echo "US/Mountain" >/etc/timezone
cat /etc/timezone
