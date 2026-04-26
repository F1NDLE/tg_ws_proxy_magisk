#!/system/bin/sh
MODDIR=${0%/*}
BIN_NAME="tg-ws-proxy"
BIN="$MODDIR/system/bin/$BIN_NAME"
LOG="$MODDIR/proxy.log"
CONF="$MODDIR/config.conf"
PID_FILE="$MODDIR/proxy.pid"

chmod 755 "$BIN"
chmod 777 "$MODDIR"

D="bm9za29tbmFkem9yLmNvLnVrIGNha2Vpc2FsaWUuY28udWsgS2FydG9zaGthLmNvLnVrIHBjbGVhZC5jby51aw=="

generate_secret() {
    echo "$(date)$RANDOM$(uptime)" | md5sum | cut -d' ' -f1
}

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm "$PID_FILE"
        echo "Статус: Остановлено"
        exit 0
    fi
    rm "$PID_FILE"
fi

if [ ! -f "$CONF" ]; then
    SECRET=$(generate_secret)
    cat <<EOF > "$CONF"
PORT=1443
HOST=127.0.0.1
SECRET=$SECRET
CF_DOMAIN=
FAKE_TLS=
AUTOSTART=OFF
EOF
else
    . "$CONF"
fi

pkill -9 "$BIN_NAME" 2>/dev/null

echo "TG WS PROXY by финдл"
echo "Статус: Запуск..."

if [ -z "$SECRET" ] || [ ${#SECRET} -ne 32 ] || echo "$SECRET" | grep -q "[^0-9a-fA-F]"; then
    SECRET=$(generate_secret)
    grep -v "^SECRET=" "$CONF" > "${CONF}.tmp"
    echo "SECRET=$SECRET" >> "${CONF}.tmp"
    mv "${CONF}.tmp" "$CONF"
fi

if [ -z "$CF_DOMAIN" ]; then
    DECODED=$(echo "$D" | base64 -d)
    BEST_DOMAIN=""
    MIN_LATENCY=9999
    for dom in $DECODED; do
        PING_RES=$(ping -c 3 -W 2 "$dom" 2>/dev/null | tail -1)
        if [ -n "$PING_RES" ]; then
            LATENCY=$(echo "$PING_RES" | cut -d'/' -f5 | cut -d'.' -f1)
            if [ -n "$LATENCY" ] && [ "$LATENCY" -lt "$MIN_LATENCY" ]; then
                MIN_LATENCY=$LATENCY
                BEST_DOMAIN=$dom
            fi
        fi
    done
    if [ -n "$BEST_DOMAIN" ]; then
        ACTIVE_CF_DOMAIN=$BEST_DOMAIN
    else
        set -- $DECODED
        shift $(($RANDOM % $#))
        ACTIVE_CF_DOMAIN=$1
    fi
else
    ACTIVE_CF_DOMAIN=$CF_DOMAIN
fi

CLEAN_DOMAIN=$(echo "$ACTIVE_CF_DOMAIN" | sed -E 's/^kws[0-9]*\.//')
rm -f "$LOG"

ARGS="--port $PORT --host $HOST --secret $SECRET --cf-domain $CLEAN_DOMAIN"
[ -n "$FAKE_TLS" ] && ARGS="$ARGS --listen-faketls-domain $FAKE_TLS"

export RUST_LOG=info
nohup $BIN $ARGS > "$LOG" 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"

for i in $(seq 1 10); do
    sleep 1
    if [ -f "$LOG" ]; then
        RAW_LINK=$(grep -o "tg://proxy?server=[^ ]*" "$LOG" | tail -n 1)
        if [ -n "$RAW_LINK" ]; then
            LINK=$(echo "$RAW_LINK" | sed "s/server=[^&]*/server=$HOST/")
            echo "Статус: Работает на порту $PORT"
            am start -a android.intent.action.VIEW -d "$LINK" >/dev/null 2>&1
            exit 0
        fi
    fi
    if ! kill -0 $NEW_PID 2>/dev/null; then
        exit 1
    fi
done
