#!/bin/bash

PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/run/${PROCESS_NAME}_pid"

MONITOR_URL="https://test.com/monitoring/test/api"
# MONITOR_URL="https://google.com"

# Проверяем, запущен ли процесс
PID=$(pgrep -f "$PROCESS_NAME -c")

if [[ -n "$PID" ]]; then
    # Проверяем, был ли процесс перезапущен
    if [[ -f "$STATE_FILE" ]]; then
        OLD_PID=$(cat "$STATE_FILE")
        if [[ "$OLD_PID" != "$PID" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME был перезапущен (PID $OLD_PID -> $PID)" >> "$LOG_FILE"
        fi
    fi
    echo "$PID" > "$STATE_FILE"

    # Стучимся на сервер мониторинга (возвращаем код HTTP ответа)
    HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 10 $MONITOR_URL)
    if [[ $? -ne 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Сервер мониторинга недоступен" >> "$LOG_FILE"
    fi
else
    # Процесс не запущен — ничего не делаем
    exit 0
fi
