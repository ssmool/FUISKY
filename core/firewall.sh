# FILE: core/firewall.sh

source config/config.conf

BANLIST="data/banned.txt"
WHITELIST="data/whitelist.txt"

block_ip() {
    IP=$1

    grep -q "$IP" "$WHITELIST" 2>/dev/null && return

    if ! grep -q "$IP" "$BANLIST" 2>/dev/null; then
        iptables -A INPUT -s "$IP" -j DROP
        echo "$IP" >> "$BANLIST"
        echo "[BAN] $IP"
    fi
}

"$@"
