#!/system/bin/sh
MODDIR=${0%/*}
BIN=$MODDIR/python/bin/python3
SCRIPT=$MODDIR/tg_ws_proxy.py
LOG=$MODDIR/proxy.log
until [ $(getprop sys.boot_completed) -eq 1 ]; do sleep 5; done
export PYTHONPATH=$MODDIR/python/lib/python3.11/site-packages:$MODDIR/python/lib/python3.11
if [ -f "$BIN" ]; then
    $BIN $SCRIPT --port 1443 --host 127.0.0.1 > $LOG 2>&1 &
fi
