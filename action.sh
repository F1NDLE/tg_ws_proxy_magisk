#!/system/bin/sh
MODDIR=${0%/*}
BIN_NAME="tg-ws-proxy"
BIN="$MODDIR/system/bin/$BIN_NAME"
LOG="$MODDIR/proxy.log"
CONF="$MODDIR/config.conf"

chmod 755 "$BIN"
chmod 777 "$MODDIR"

[ -f "$CONF" ] && . "$CONF"

PORT=${PORT:-1443}
HOST=${HOST:-127.0.0.1}

PID=$(pgrep -f "$BIN_NAME")

if [ -z "$PID" ]; then
    echo "TG WS PROXY by финдл"
    echo "Статус: Запуск..."
    : > "$LOG"

    ARGS="--port $PORT --host $HOST --log-file $LOG"
    [ -n "$SECRET" ] && ARGS="$ARGS --secret $SECRET"
    [ -n "$CF_DOMAIN" ] && ARGS="$ARGS --cf-domain $CF_DOMAIN"
    [ -n "$EXTRA_ARGS" ] && ARGS="$ARGS $EXTRA_ARGS"

    $BIN $ARGS > "$LOG" 2>&1 &
    NEW_PID=$!
    
    LINK=""
    for i in $(seq 1 10); do
        sleep 1
        if [ -f "$LOG" ]; then
            RAW_LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
            if [ -n "$RAW_LINK" ]; then
                LINK=$(echo "$RAW_LINK" | sed "s/server=[^&]*/server=$HOST/")
                break
            fi
        fi
        if ! kill -0 $NEW_PID 2>/dev/null; then
            echo "ОШИБКА: процесс завершился"
            cat "$LOG"
            exit 1
        fi
    done
    
    if [ -n "$LINK" ]; then
        echo "Статус: Работает на порту $PORT"
        am start --user 0 -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
    else
        echo "Ссылка не найдена. Содержимое лога:"
        cat "$LOG"
    fi
else
    kill -9 "$PID"
    echo "Статус: Остановлено"
fi
