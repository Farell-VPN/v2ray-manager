#!/bin/bash

# Fix Nameserver
[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || {
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf >> /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}

clear

echo -e "
+-+-+-+-+-+-+-+-+-+-+-+-+
|F|A|R|E|L| |A|D|I|T|Y|A|
+-+-+-+-+-+-+-+-+-+-+-+-+
"

clear


# Update Default Server Package
apt update

# Install Package System
apt install wget curl -y
apt install binutils -y
apt install libssl-dev -y
apt install openssl -y
apt install gnupg -y
apt install mysql-server -y
apt install socat -y
apt install certbot -y
apt install vnstat -y
apt install cron -y
apt install git -y

# Setup Manual Package

# Setup Argo / Cloudflare Panel
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm -fr cloudflared-linux-amd64.deb
rm -fr /etc/cloudflared/*
mkdir -p /etc/cloudflared

clear

