#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE="$MODDIR/proxy_debug.log"

echo "--- LOG START: $(date) ---" > "$LOGFILE"

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
done

chmod +x "$MODDIR/python/bin/python3"
export PYTHONHOME="$MODDIR/python"
export PYTHONPATH="$MODDIR/python/lib/python3.13:$MODDIR/lib"
export LD_LIBRARY_PATH="$MODDIR/python/lib:/system/lib64:/system/lib"

$MODDIR/python/bin/python3 "$MODDIR/lib/proxy/tg_ws_proxy.py" --port 1080 >> "$LOGFILE" 2>&1 &

