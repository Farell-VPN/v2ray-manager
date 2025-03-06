#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1
API_STATS=$(v2ray api stats --server=127.0.0.1:10085)

# Filter baris yang sesuai dengan user
TRAFFIC_LINES=$(echo "$API_STATS" | grep "user>>>$USERNAME>>>traffic>>>")

TOTAL_BYTES=0

# Fungsi konversi dari satuan ke byte
convert_to_bytes() {
    local VALUE="$1"
    local UNIT="${VALUE//[^a-zA-Z]/}"
    local NUMBER="${VALUE//[^0-9.e+-]/}" # Menangani angka dalam notasi ilmiah

    case "$UNIT" in
        B) echo "$NUMBER" ;;
        KB) echo "$(echo "scale=10; $NUMBER * 1024" | bc)" ;;
        MB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024" | bc)" ;;
        GB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024" | bc)" ;;
        TB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024 * 1024" | bc)" ;;
        PB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024 * 1024 * 1024" | bc)" ;;
        EB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024 * 1024 * 1024 * 1024" | bc)" ;;
        ZB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024" | bc)" ;;
        YB) echo "$(echo "scale=10; $NUMBER * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024" | bc)" ;;
        *) echo "$NUMBER" ;; # Default jika tidak ada satuan
    esac
}

for LINE in $TRAFFIC_LINES; do
    if [[ "$LINE" =~ ^[0-9]+(\.[0-9]+)?(e[+-][0-9]+)?(B|KB|MB|GB|TB|PB|EB|ZB|YB)$ ]]; then
        BYTES=$(convert_to_bytes "$LINE")
        TOTAL_BYTES=$(echo "scale=10; $TOTAL_BYTES + $BYTES" | bc)
    fi
done

# Fungsi konversi ke format yang lebih mudah dibaca
convert_from_bytes() {
    local BYTES="$1"
    local UNITS=("B" "KB" "MB" "GB" "TB" "PB" "EB" "ZB" "YB")
    local i=0

    while (( $(echo "$BYTES >= 1024" | bc -l) )) && (( i < ${#UNITS[@]} - 1 )); do
        BYTES=$(echo "scale=10; $BYTES / 1024" | bc)
        ((i++))
    done

    echo "$(printf "%.2f" "$BYTES") ${UNITS[$i]}"
}

TOTAL_HUMAN_READABLE=$(convert_from_bytes "$TOTAL_BYTES")

#echo "Total traffic for user '$USERNAME': $TOTAL_HUMAN_READABLE"

echo -e "$TOTAL_HUMAN_READABLE"