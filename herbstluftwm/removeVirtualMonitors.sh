#!/bin/bash

VIRTUAL_MONITOR_KEY=${VIRTUAL_MONITOR_KEY:-"hlwm"}

xrandr --listactivemonitors | grep "$VIRTUAL_MONITOR_KEY" | while read s; do
    if [[ $s =~ ([-[:alnum:]_]*-hlwm[[:digit:]]) ]]; then
        HLWM_MONITOR=${BASH_REMATCH[0]}
        xrandr --delmonitor $HLWM_MONITOR
    fi
done

