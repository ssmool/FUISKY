# FILE: core/correlator.sh

source config/config.conf

declare -A COUNT

tail -Fn0 data/events.log | while read line; do

    TYPE=$(echo "$line" | cut -d'|' -f2 | xargs)
    IP=$(echo "$line" | cut -d'|' -f3 | xargs)

    KEY="$TYPE-$IP"
    ((COUNT[$KEY]++))

    if (( COUNT[$KEY] >= THRESHOLD )); then
        echo "[ALERT] $TYPE $IP"
        bash core/firewall.sh block_ip "$IP"
    fi

done
