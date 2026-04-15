# FILE: core/logger.sh

log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1 | $2" >> data/events.log
}
