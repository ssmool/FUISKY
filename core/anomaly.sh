# FILE: core/anomaly.sh

source config/config.conf
source core/logger.sh

while true; do

    LOAD=$(uptime | awk '{print $10}' | cut -d. -f1)
    CONN=$(ss -ant | wc -l)

    if (( LOAD > MAX_LOAD )); then
        log_event "HIGH_LOAD" "$LOAD"
    fi

    if (( CONN > MAX_CONN )); then
        log_event "DDOS_SUSPECT" "$CONN"
    fi

    sleep 5
done
