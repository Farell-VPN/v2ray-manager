#!/bin/bash

# Configuration Variables
database="/usr/local/etc/v2ray/database.db"
json="/usr/local/etc/v2ray/config.json"
log_file="/usr/local/etc/v2ray/vless.log"

# Ensure config.json is valid before modifying
if ! jq empty "$json" >/dev/null 2>&1; then
    echo "Error: config.json is not valid!"
    exit 1
fi

# Get today's date
today=$(date +"%Y-%m-%d")

# Fetch expired accounts from the database
expired_users=$(sqlite3 "$database" "SELECT email, uuid, expired FROM vless WHERE expired <= '$today';")

# Check if there are any expired accounts
if [[ -z "$expired_users" ]]; then
    echo "No expired accounts found."
    exit 0
fi

echo -e "\n=== Expired vless Accounts ==="
echo -e "Today's Date: $today\n"

# Loop through expired accounts to display and delete them
while IFS='|' read -r user uuid exp_date; do
    if [[ -n "$user" && -n "$uuid" ]]; then
        echo -e "Username  : $user"
        echo -e "UUID      : $uuid"
        echo -e "Expired   : $exp_date"
        echo -e "Status    : \e[31mDeleted\e[0m\n"

        # Log the deleted account
        echo "$today - $user - $uuid - $exp_date - Deleted" >> "$log_file"

        # Remove account from config.json
        jq --arg uuid "$uuid" '
          (.inbounds[] | select(.protocol=="vless").settings.clients) |= 
          map(select(.id != $uuid))
        ' "$json" > /tmp/config.json && mv /tmp/config.json "$json"

        # Remove account from the database
        sqlite3 "$database" "DELETE FROM vless WHERE email='$user';"
    fi
done <<< "$expired_users"

# Restart V2Ray service to apply changes
systemctl restart v2ray

echo -e "\nProcess complete. All expired accounts have been deleted and logged to: $log_file\n"