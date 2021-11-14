#!/bin/bash

. ./monitorGeometry.sh

VIRTUAL_MONITOR_KEY="hlwm"

remove_virtual_monitors() { 
    xrandr --listactivemonitors | grep "$VIRTUAL_MONITOR_KEY" | while read s; do
        if [[ $s =~ ([-[:alnum:]_]*-hlwm[[:digit:]]) ]]; then
            local HLWM_MONITOR=${BASH_REMATCH[0]}
            xrandr --delmonitor $HLWM_MONITOR
        fi
    done
}

create_virtual_monitors() {
    local origMonitor="$1"
    shift
    local monitors=("$@")
    for i in "${!monitors[@]}"; do
       if [ $i -eq 0 ]; then
            xrandr --setmonitor "$origMonitor-$VIRTUAL_MONITOR_KEY$i" "${monitors[$i]}" "$origMonitor"
        else
            xrandr --setmonitor "$origMonitor-$VIRTUAL_MONITOR_KEY$i" "${monitors[$i]}" none
        fi
    done
}

split_once() {
    remove_virtual_monitors
    local geometry=$(extract_geometry "$1")
    echo "Geometry $geometry"
    local newMonitors=( $(divide_vertical "$geometry") )
    echo "New monitors ${newMonitors[*]}"
    create_virtual_monitors "$1" ${newMonitors[*]}
}

#GEOMETRY=$(extract_geometry $@)
#echo $GEOMETRY
#THREE=( $(divide_three $GEOMETRY) )
#echo ${THREE[@]}
#create_virtual_monitors $@ "${THREE[@]}"
#largest_monitor
#primary_monitor
echo "$(extract_geometry "LVDS")"
split_once "LVDS"
