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

largest_monitor() {
    local monitors=()
    while read m; do
        if [[ $m =~ (^[-[:alnum:]_]*)[^[:digit:]]*([[:digit:]]+)x([[:digit:]]+)\+[[:digit:]]+\+[[:digit:]]+ ]]; then
            local size=$( expr ${BASH_REMATCH[2]} \* ${BASH_REMATCH[3]} )
            local thisMonitor="$size,${BASH_REMATCH[1]}"
            monitors+=($thisMonitor)
        fi
    done <<< $(xrandr --query | grep " connected")
    if [[ ${#monitors[@]} -gt 1 ]]; then
        IFS=$'\n' monitors=($(sort -b -n -r -t , -k 1 <<<"${monitors[*]}")); unset IFS
    fi
    if [[ ${monitors[0]} =~ [[:digit:]]*,(.*) ]]; then
        echo ${BASH_REMATCH[1]}
    fi
}

primary_monitor() {
    local xrandrData=$(xrandr --query | grep "primary")
    if [[ $xrandrData =~ (^[-[:alnum:]_]*).* ]]; then
        echo ${BASH_REMATCH[1]}
    fi
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
