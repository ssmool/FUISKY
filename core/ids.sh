# FILE: core/ids.sh

source core/logger.sh
source config/config.conf

tail -Fn0 $LOG_AUTH $LOG_SYS | while read line; do

    if echo "$line" | grep -q "Failed password"; then
        IP=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
        log_event "SSH_FAIL" "$IP"
    fi

    if echo "$line" | grep -q "SYN"; then
        IP=$(echo "$line" | grep -oE 'SRC=[0-9.]+' | cut -d= -f2)
        log_event "PORT_SCAN" "$IP"
    fi

done
