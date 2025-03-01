#!/bin/bash

clear

echo -e "
+-+-+-+-+-+-+-+-+-+-+-+-+
|F|A|R|E|L| |A|D|I|T|Y|A|
+-+-+-+-+-+-+-+-+-+-+-+-+
"

# Setup Core V2rayfly
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

# Fixed Service Service
cd /etc/systemd/system
sed -i 's|DynamicUser=true|User=root|g' v2ray.service
sed -i 's|User=nobody|User=root|g' v2ray.service
cd

clear

# Setup Json
wget -O /usr/local/etc/v2ray/config.json "https://raw.githubusercontent.com/Farell-VPN/v2ray-manager/refs/heads/main/json/config.json"

# Permision Log
rm -fr /var/log/v2ray
mkdir -p /var/log/v2ray
touch /var/log/v2ray/access.log
touch /var/log/v2ray/error.log
chmod 755 /var/log/v2ray/access.log
chown root:root /var/log/v2ray/access.log
chmod 755 /var/log/v2ray/error.log
chown root:root /var/log/v2ray/error.log

# Start Service
systemctl daemon-reload
systemctl enable v2ray
systemctl start v2ray
systemctl restart v2ray

clear
