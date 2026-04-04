#!/system/bin/sh
MODDIR=${0%/*}
BIN=$MODDIR/python/bin/python3
SCRIPT=$MODDIR/tg_ws_proxy.py
LOG=$MODDIR/proxy.log


export LD_LIBRARY_PATH="$MODDIR/python/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$MODDIR/python/lib/python3.11/site-packages:$MODDIR/python/lib/python3.11"

PID=$(pgrep -f "$SCRIPT")

if [ -z "$PID" ]; then
    echo "TG WS PROXY by финдл"
    
    $BIN $SCRIPT --port 1443 --host 127.0.0.1 --buf-kb 512 --pool-size 10 > $LOG 2>&1 &
    
    sleep 3
    
    NEW_PID=$(pgrep -f "$SCRIPT")
    if [ -n "$NEW_PID" ]; then
        echo "СТАТУС: ЗАПУЩЕН (ТЮНИНГ: ВКЛ)"
        
        LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
        
        if [ -n "$LINK" ]; then
            am start --user 0 -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
            echo "запуск"
            echo "ПРОКСИ ОТКРЫТ В TELEGRAM"
            echo "Открываю"
        else
            echo "ОШИБКА: Ссылка не найдена"
        fi
    else
        echo "ОШИБКА ЗАПУСКА"
    fi
else
    echo "TG WS PROXY by финдл"
    kill "$PID"
    echo "СТАТУС: ОСТАНОВЛЕН"
fi