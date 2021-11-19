#!/bin/bash

killall polybar
while read m; do
    if [[ "$m" =~ \+?\*?(.*) ]]; then
        MONITOR="${BASH_REMATCH[1]}" polybar myBar &
    fi
    MONITOR="$m" polybar myBar &
done <<< $(xrandr --listactivemonitors | tail -n +2 | cut -d ' ' -f 3)

