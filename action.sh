#!/system/bin/sh
MODDIR=${0%/*}
BIN=$MODDIR/python/bin/python3
SCRIPT=$MODDIR/tg_ws_proxy.py
LOG=$MODDIR/proxy.log
PID=$(pgrep -f "$SCRIPT")

if [ -z "$PID" ]; then
    echo "TG PROXY, by финдл"
    export PYTHONPATH=$MODDIR/python/lib/python3.11/site-packages:$MODDIR/python/lib/python3.11
    $BIN $SCRIPT --port 1443 --host 127.0.0.1 > $LOG 2>&1 &
    
    sleep 3
    
    NEW_PID=$(pgrep -f "$SCRIPT")
    if [ -n "$NEW_PID" ]; then
        echo "СТАТУС: ЗАПУЩЕН"
        
        LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
        
        if [ -n "$LINK" ]; then
            am start --user 0 -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
            echo "Запуск"
            echo "ПРОКСИ ОТКРЫТ В TELEGRAM"
            echo "$LINK"
            echo "Открытие"
        else
            echo "ошибка: ссылка не найдена"
        fi
    else
        echo "ошибка запуска"
    fi
else
    echo "TG PROXY, by финдл"
    kill "$PID"
    echo "СТАТУС: ОСТАНОВЛЕН"
fi
