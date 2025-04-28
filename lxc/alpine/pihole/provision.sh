#!/bin/sh

echo "APP_VERSION: ${APP_VERSION}"
echo "ARCH: ${ARCH}"

apk update

# First, install the required packages
apk update
apk add --no-cache \
    bash \
    curl \
    git \
    python3 \
    py3-pip \
    lighttpd \
    php82 \
    php82-common \
    php82-session \
    php82-json \
    php82-xml \
    php82-sqlite3 \
    php82-pdo \
    php82-pdo_sqlite \
    php82-opcache \
    php82-mbstring \
    php82-ctype \
    php82-posix \
    php82-fileinfo \
    php82-curl \
    php82-openssl \
    php82-iconv \
    php82-simplexml \
    php82-dom \
    php82-xmlreader \
    php82-xmlwriter \
    php82-tokenizer \
    php82-phar \
    php82-gd \
    php82-intl \
    php82-zip \
    php82-zlib \
    php82-bcmath \
    php82-gmp \
    php82-sodium \
    php82-ftp \
    php82-ldap \
    php82-pgsql \
    php82-pdo_pgsql \
    php82-pdo_mysql \
    php82-mysqli \
    php82-exif \
    php82-pecl-imagick \
    php82-pecl-memcached \
    php82-pecl-redis \
    php82-pecl-mongodb \
    php82-pecl-igbinary \
    php82-pecl-msgpack \
    php82-pecl-apcu \
    dnsmasq \
    coreutils \
    findutils \
    grep \
    sed \
    wget \
    tar \
    gzip \
    xz

git clone --depth 1 https://github.com/pi-hole/pi-hole.git /etc/.pihole

mkdir -p /var/www/html /etc/pihole /etc/dnsmasq.d

# Clone the AdminLTE repository
#git clone --depth 1 https://github.com/pi-hole/AdminLTE.git /var/www/html/admin
git clone --depth 1 https://github.com/pi-hole/AdminLTE.git /var/www/localhost/htdocs

# Copy Pi-hole files
cp /etc/.pihole/gravity.sh /usr/local/bin/
cp /etc/.pihole/pihole /usr/local/bin/

cat > /etc/pihole/setupVars.conf << EOF
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=0.0.0.0
IPV6_ADDRESS=
QUERY_LOGGING=true
INSTALL_WEB=true
DNSMASQ_LISTENING=local
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSSEC=false
TEMPERATUREUNIT=F
WEBUIBOXEDLAYOUT=traditional
WEBPASSWORD=a450425a9da3c27f3430ed153d19e9a647f7f6ad2e11f5836cd10a9c2b94d6c3
BLOCKING_ENABLED=true
PIHOLE_DNS_1=8.8.8.8
PIHOLE_DNS_2=8.8.4.4
EOF

cat > /etc/dnsmasq.d/01-pihole.conf << EOF
addn-hosts=/etc/pihole/gravity.list
localise-queries
no-resolv
no-poll
no-negcache
cache-size=10000
local-ttl=2
EOF

rc-update add dnsmasq default
rc-update add lighttpd default

/etc/init.d/dnsmasq start
/etc/init.d/lighttpd start

