#!/bin/bash
# Dinda Putri Cindyani

# Variabel Konfigurasi
domain=$(cat /usr/local/etc/v2ray/domain)
uuid=$(cat /proc/sys/kernel/random/uuid)
telegram_bot_token=$(cat /etc/funny/bot/notif/bot.key)
telegram_chatid=$(cat /etc/funny/bot/notif/client.id)
database="/usr/local/etc/v2ray/database.db"
json="/usr/local/etc/v2ray/config.json"
isp=$(cat /root/.isp)
region=$(cat /root/.region)

clear
echo -e "\e[33m\033[0m" | lolcat
echo -e "                  Rerechan02                  "
echo -e "\e[33m\033[0m" | lolcat
echo -e ""
echo -e " Informasi menambah akun VMess"
echo -e ""
echo -e " Format Masa Aktif (hari):"
echo -e " Masa aktif akun yang ingin dibuat"
echo -e "\e[33m\033[0m" | lolcat
echo -e ""

# Fungsi untuk mengecek apakah username sudah ada di database
function cek_username() {
    local user="$1"
    result=$(sqlite3 $database "SELECT COUNT(*) FROM vmess WHERE email='$user';")
    if [[ $result -gt 0 ]]; then
        return 0
    fi
    return 1
}

# Loop untuk meminta username sampai ditemukan yang belum terpakai
while true; do
    read -p " Username         : " user
    if cek_username "$user"; then
        echo -e "\e[31mUsername is already in use, please choose another username.\e[0m"
    else
        break
    fi
done

# Input Masa Aktif
read -p " Masa aktif (hari): " masaaktif
now=$(date -d "0 days" +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Insert data VMess ke database SQLite
alterid=0  # Default alterid untuk VMess
sqlite3 $database "INSERT INTO vmess (email, alterid, uuid, expired) VALUES ('$user', $alterid, '$uuid', '$exp');"

# Pastikan config.json valid sebelum mengubah
if ! jq empty "$json" >/dev/null 2>&1; then
    echo " Error: config.json tidak valid!"
    exit 1
fi

# Tambahkan akun ke dalam config.json
jq --arg uuid "$uuid" --arg email "$user" '
  (.inbounds[] | select(.protocol=="vmess").settings.clients) += [{"id": $uuid, "alterId": 0, "email": $email}]
' "$json" > /tmp/config.json && mv /tmp/config.json "$json"

# Cek apakah akun berhasil ditambahkan
if jq -e --arg uuid "$uuid" '.inbounds[] | select(.protocol=="vmess").settings.clients[] | select(.id == $uuid)' "$json" >/dev/null; then
    echo " Akun berhasil ditambahkan ke config.json!"
else
    echo " Gagal menambahkan akun ke config.json!"
    exit 1
fi

# Restart layanan yang dibutuhkan
systemctl restart v2ray
systemctl restart quota

clear

# Buat JSON untuk link VMess
acs=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${domain}",
  "port": "443",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/vmessws",
  "type": "none",
  "host": "${domain}",
  "tls": "tls"
}
EOF
)
ask=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${domain}",
  "port": "80",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/worryfree",
  "type": "none",
  "host": "${domain}",
  "tls": "none"
}
EOF
)

# Link VMess
vmesslink1="vmess://$(echo $acs | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"

# Kirim Notifikasi Telegram
clear
TEKS=$(cat <<EOF
<b></b>
<b>    &lt; VMESS ACCOUNT &gt;    </b>
<b></b>
<b>Host/IP      :</b> <code>${domain}</code>
<b>Username     :</b> <code>${user}</code>
<b>ISP          :</b> <code>${isp}</code>
<b>Region       :</b> <code>${region}</code>
<b>Port ssl/tls :</b> <code>443</code>
<b>Port nonetls :</b> <code>80, 2082</code>
<b>UUID         :</b> <code>${uuid}</code>
<b>Network      :</b> <code>websocket</code>
<b>Path         :</b> <code>/vmessws</code>
<b>Path Opok    :</b> <code>/worryfree /kuota-habis</code>

<b></b>
<b>Link TLS     :</b>
<pre>${vmesslink1}</pre>
<b></b>
<b>Link None    :</b>
<pre>${vmesslink2}</pre>
<b></b>
<b>Expired      :</b> <code>${exp}</code>
<b></b>
EOF
)

curl -s -X POST "https://api.telegram.org/bot$telegram_bot_token/sendMessage" \
    -d "chat_id=$telegram_chatid" \
    -d "parse_mode=HTML" \
    --data-urlencode "text=$TEKS" > /dev/null

# Menampilkan Data Akun
echo -e ""
echo -e "    <  VMESS ACCOUNT >"
echo -e ""
echo -e ""
echo -e "Host/IP      : $domain"
echo -e "Username     : $user"
echo -e "ISP          : $isp"
echo -e "Region       : $region"
echo -e "Port ssl/tls : 443"
echo -e "Port nonetls : 80, 2082"
echo -e "UUID         : $uuid"
echo -e "Network      : websocket"
echo -e "Path         : /vmessws"
echo -e "Path Opok    : /worryfree /kuota-habis"
echo -e ""
echo -e "Link TLS     : $vmesslink1"
echo -e ""
echo -e "Link None    : $vmesslink2"
echo -e ""
echo -e "Expired      : $exp"
echo -e ""