#!/system/bin/sh
MODDIR=${0%/*}
BIN_NAME="tg-ws-proxy"
BIN="$MODDIR/system/bin/$BIN_NAME"
LOG="$MODDIR/proxy.log"

chmod 775 /data/adb/modules/tg_ws_proxy_f1ndle/system/bin/tg-ws-proxy

PID=$(pgrep -f "$BIN_NAME")

if [ -z "$PID" ]; then
    echo "TG WS PROXY by финдл"
    : > "$LOG"

    $BIN --port 1443 --host 127.0.0.1 > "$LOG" 2>&1 &
    
    NEW_PID=$!
    LINK=""

    for i in $(seq 1 10); do
        sleep 1
        RAW_LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
        if [ -n "$RAW_LINK" ]; then
            LINK=$(echo "$RAW_LINK" | sed 's/server=[^&]*/server=127.0.0.1/')
            break
        fi
        
        if ! kill -0 $NEW_PID 2>/dev/null; then
            echo "ОШИБКА: процесс сдох (картинка: пацан бьёт по столу, представь, что она тут)"
            exit 1
        fi
    done
    
    if [ -n "$LINK" ]; then
        echo "Статус: Работает :)"
        am start --user 0 -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
    else
        echo "ОШИБКА: ссылка не найдена! -_-, странно... не так ли? "
        tail -n 5 "$LOG"
    fi
else
    echo "TG WS PROXY by финдл"
    kill -9 "$PID"
    echo "Статус: Остановлено >⁠.⁠<"
    : > "$LOG"
fi
