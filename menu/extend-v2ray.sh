#!/bin/bash

database="/usr/local/etc/v2ray/database.db"

clear

echo "====================================================="
echo "               Extend Akun V2Ray                     "
echo "====================================================="
echo "Protocol   Username      Expired"
echo "-----------------------------------------------------"

# Fungsi untuk menampilkan akun berdasarkan protokol
function list_accounts() {
    local protocol=$1

    sqlite3 "$database" "SELECT email, expired FROM $protocol;" | while IFS='|' read -r email expired
    do
        printf "%-10s %-12s %-36s %s\n" "$protocol" "$email" "$expired"
    done
}

# Menampilkan daftar akun dari setiap protokol
list_accounts "vmess"
list_accounts "vless"
list_accounts "trojan"

echo "-----------------------------------------------------"

# Meminta input untuk akun dan opsi custom expired
read -p "Enter protocol (vmess/vless/trojan): " protocol
read -p "Enter username/email to extend: " email
read -p "Do you want to set custom expiration date? (y/n): " custom_expired

# Fungsi untuk memvalidasi format tanggal (YYYY-MM-DD)
validate_date_format() {
    if [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Jika custom expired dipilih
if [[ "$custom_expired" == "y" ]]; then
    # Meminta input custom expired
    while true; do
        read -p "Enter custom expiration date (YYYY-MM-DD): " custom_date
        if validate_date_format "$custom_date"; then
            break
        else
            echo "Invalid date format. Please use YYYY-MM-DD format."
        fi
    done

    # Memperbarui tanggal expired di database
    sqlite3 "$database" "UPDATE $protocol SET expired = '$custom_date' WHERE email = '$email';"

    # Menampilkan hasil
    if [[ $? -eq 0 ]]; then
        echo "Account for $email in protocol $protocol has been updated to $custom_date."
    else
        echo "Error updating account for $email."
    fi
else
    # Jika tidak menggunakan custom expired, memperpanjang masa aktif berdasarkan jumlah hari
    read -p "Enter number of days to extend: " days_to_extend

    # Mengambil tanggal expired saat ini dari database
    current_expired=$(sqlite3 "$database" "SELECT expired FROM $protocol WHERE email='$email';")

    # Jika akun ditemukan
    if [[ -n "$current_expired" ]]; then
        # Menghitung tanggal expired baru dengan menambahkan jumlah hari
        new_expired_date=$(date -d "$current_expired + $days_to_extend days" +"%Y-%m-%d")

        # Memperbarui tanggal expired di database
        sqlite3 "$database" "UPDATE $protocol SET expired = '$new_expired_date' WHERE email = '$email';"

        # Menampilkan hasil
        if [[ $? -eq 0 ]]; then
            echo "Account for $email in protocol $protocol has been extended to $new_expired_date."
        else
            echo "Error updating account for $email."
        fi
    else
        echo "Account $email not found in protocol $protocol."
    fi
fi