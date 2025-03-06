#!/bin/bash

database="/usr/local/etc/v2ray/database.db"

clear

echo "====================================================="
echo "                 List Akun V2Ray                     "
echo "====================================================="
echo "Protocol   Username      UUID/Password               Expired"
echo "-----------------------------------------------------"

function list_accounts() {
    local protocol=$1
    local uuid_column="uuid"

    if [[ "$protocol" == "trojan" ]]; then
        uuid_column="password"
    fi

    sqlite3 $database "SELECT email, $uuid_column, expired FROM $protocol;" | while IFS='|' read -r email uuid expired
    do
        printf "%-10s %-12s %-36s %s\n" "$protocol" "$email" "$uuid" "$expired"
    done
}

list_accounts "vmess"
list_accounts "vless"
list_accounts "trojan"

echo "-----------------------------------------------------"