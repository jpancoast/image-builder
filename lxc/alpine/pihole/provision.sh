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

git clone --depth 1 https://github.com/pi-hole/AdminLTE.git /var/www/html/admin

touch /etc/pihole/setupVars.conf

echo 'conf-dir=/etc/dnsmasq.d/,*.conf' > /etc/dnsmasq.conf

sh -c 'echo "conf-dir=/etc/dnsmasq.d/,*.conf" > /etc/dnsmasq.conf'

rc-update add dnsmasq default
/etc/init.d/dnsmasq start
/etc/init.d/lighttpd start





