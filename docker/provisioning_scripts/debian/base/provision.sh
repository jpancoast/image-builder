#!/bin/sh

apt-get update -y
apt-get upgrade -y

echo "search $DNS_SEARCH_DOMAIN" >/etc/resolv.conf
echo "nameserver $DNS_1" >>/etc/resolv.conf
echo "nameserver $DNS_2" >>/etc/resolv.conf
