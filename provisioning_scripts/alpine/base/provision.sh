#!/bin/sh

echo "search $DNS_SEARCH_DOMAIN" >/etc/resolv.conf
echo "nameserver $DNS_1" >>/etc/resolv.conf
echo "nameserver $DNS_2" >>/etc/resolv.conf

apk update
apk upgrade
apk add --no-cache tzdata
echo "US/Mountain" >/etc/timezone
cp /usr/share/zoneinfo/US/Mountain /etc/localtime
apk del tzdata
