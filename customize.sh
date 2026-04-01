#!/ui/sh
ui_print "- TG WS Proxy (MTProto) by F1NDLE"
set_perm_recursive $MODPATH 0 0 0755 0755
if [ -d "$MODPATH/python" ]; then
    set_perm_recursive $MODPATH/python 0 0 0755 0755
    chmod +x $MODPATH/python/bin/python3
fi
