#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE="$MODDIR/proxy_debug.log"
SCRIPT_PATH="$MODDIR/lib/proxy/tg_ws_proxy.py"

export PYTHONHOME="$MODDIR/python"
export PYTHONPATH="$MODDIR/python/lib/python3.13:$MODDIR/lib"
export LD_LIBRARY_PATH="$MODDIR/python/lib:/system/lib64:/system/lib"

PID=$(pgrep -f "tg_ws_proxy.py")

if [ ! -z "$PID" ]; then
    echo "СТАТУС: РАБОТАЕТ (PID: $PID)"
    echo "Останавливаю..."
    kill $PID
    echo "Остановлен."
else
    echo "СТАТУС: НЕ ЗАПУЩЕН"
    echo "Запуск..."
    chmod +x "$MODDIR/python/bin/python3"
    $MODDIR/python/bin/python3 "$SCRIPT_PATH" --port 1080 >> "$LOGFILE" 2>&1 &
    sleep 2
    if pgrep -f "tg_ws_proxy.py" > /dev/null; then
        echo "Успешно запущен!"
    else
        echo "ОШИБКА ЗАПУСКА. Лог:"
        tail -n 10 "$LOGFILE"
    fi
fi

