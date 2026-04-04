#!/system/bin/sh
MODDIR=${0%/*}
BIN=$MODDIR/python/bin/python3
SCRIPT=$MODDIR/tg_ws_proxy.py
LOG=$MODDIR/proxy.log

chmod 755 "/data/adb/modules/tg_ws_proxy_f1ndle/python/bin/python3"

chmod 755 "/data/adb/modules/tg_ws_proxy_f1ndle/python/lib/libandroid-posix-semaphore.so"

export LD_LIBRARY_PATH="$MODDIR/python/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$MODDIR/python/lib/python3.11/site-packages:$MODDIR/python/lib/python3.11"

PID=$(pgrep -f "$SCRIPT")

if [ -z "$PID" ]; then
    echo "TG WS PROXY by финдл"
    
    $BIN $SCRIPT --port 1443 --host 127.0.0.1 --buf-kb 512 --pool-size 10 > $LOG 2>&1 &
    
    LINK=""
    for i in 1 2 3 4 5 6 7 8 9 10; do
        sleep 1
        LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
        if [ -n "$LINK" ]; then
            break
        fi
        if ! pgrep -f "$SCRIPT" >/dev/null; then
            echo "ОШИБКА ЗАПУСКА (процесс умер)"
            exit 1
        fi
    done
    
    if [ -n "$LINK" ]; then
        echo "СТАТУС: ЗАПУЩЕН"
        am start --user 0 -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
        echo "ПРОКСИ ОТКРЫТ В TELEGRAM"
    else
        echo "ОШИБКА: Ссылка не найдена за 10 секунд"
        tail -n 5 "$LOG"
    fi
else
    echo "TG WS PROXY by финдл"
    kill "$PID"
    echo "СТАТУС: ОСТАНОВЛЕН"
fi