#!/system/bin/sh
MODDIR=${0%/*}
BIN="$MODDIR/system/bin/tg-ws-proxy"
CONF="$MODDIR/config.conf"

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
done

if [ -f "$CONF" ]; then
    . "$CONF"
fi

if [ "$AUTOSTART" = "ON" ] && [ -n "$SECRET" ]; then
    ARGS="--port ${PORT:-1443} --host ${HOST:-127.0.0.1} --secret $SECRET"
    [ -n "$CF_DOMAIN" ] && ARGS="$ARGS --cf-domain $CF_DOMAIN"
    
    $BIN $ARGS --log-file "$MODDIR/proxy.log" > /dev/null 2>&1 &
fi
