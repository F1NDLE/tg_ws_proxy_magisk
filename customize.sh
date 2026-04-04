#!/system/bin/sh
MODPATH=${0%/*}
mkdir -p "$MODPATH/python/lib"
mkdir -p "$MODPATH/python/lib/python3.11"
mkdir -p "$MODPATH/python/lib/python3.11/site-packages"
[ -f "$MODPATH/python/bin/python3" ] && chmod 755 "$MODPATH/python/bin/python3"
if [ ! -f "$MODPATH/python/lib/libandroid-posix-semaphore.so" ]; then
    TERMUX_LIB="/data/data/com.termux/files/usr/lib/libandroid-posix-semaphore.so"
    [ -f "$TERMUX_LIB" ] && cp "$TERMUX_LIB" "$MODPATH/python/lib/" && chmod 755 "$MODPATH/python/lib/libandroid-posix-semaphore.so"
fi
chmod 755 "$MODPATH/python/lib"