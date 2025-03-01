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
