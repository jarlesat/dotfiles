VIRTUAL_MONITOR_KEY=${VIRTUAL_MONITOR_KEY:-"hlwm"}

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
            ./debug.sh "xrandr --setmonitor $origMonitor-$VIRTUAL_MONITOR_KEY$i ${monitors[$i]} $origMonitor"
        else
            xrandr --setmonitor "$origMonitor-$VIRTUAL_MONITOR_KEY$i" "${monitors[$i]}" none
            ./debug.sh "xrandr --setmonitor $origMonitor-$VIRTUAL_MONITOR_KEY$i ${monitors[$i]} none"
        fi
    done
}

