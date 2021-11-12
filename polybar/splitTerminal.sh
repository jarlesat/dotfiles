#!/bin/bash

extract_geometry() {
    # xrandrData something like:DIV1 connected primary 3840x2160+0+0 (normal left inverted right x axis y axis) 400mm x 200mm
    local xrandrData=$(xrandr --query | grep "$@")

    if [[ $xrandrData =~ ([[:digit:]]+)x([[:digit:]]+)\+([[:digit:]]+)\+([[:digit:]]+) ]]; then
        local widthPixels=${BASH_REMATCH[1]}
        local heightPixels=${BASH_REMATCH[2]}
        local offsetX=${BASH_REMATCH[3]}
        local offsetY=${BASH_REMATCH[4]}
    fi

    if [[ $xrandrData =~ ([[:digit:]]+)mm\ x\ ([[:digit:]]+)mm ]]; then
        local widthMm=${BASH_REMATCH[1]}
        local heightMm=${BASH_REMATCH[2]}
    fi

    printf "%d/%dx%d/%d+%d+%d" $widthPixels $widthMm $heightPixels $heightMm $offsetX $offsetY
}

divide_vertical() {
    local leftNumerator=${2:-50}
    local leftDivisor=${3:-100}

    # format 3840/400x2160/200+0+0
    if [[ $1 =~ ([[:digit:]]+)/([[:digit:]]+)x([[:digit:]]+)/([[:digit:]]+)\+([[:digit:]]+)\+([[:digit:]]+) ]]; then
        local widthPixels=${BASH_REMATCH[1]}
        local widthMm=${BASH_REMATCH[2]}
        local heightPixels=${BASH_REMATCH[3]}
        local heightMm=${BASH_REMATCH[4]}
        local offsetX=${BASH_REMATCH[5]}
        local offsetY=${BASH_REMATCH[6]}
    else
        echo "ERROR"
        exit 1
    fi

    local widthPixelsLeft=$(expr $widthPixels \* $leftNumerator / $leftDivisor)
    local widthPixelsRight=$(expr $widthPixels - $widthPixelsLeft)

    local offsetXLeft=$offsetX
    local offsetXRight=$(expr $offsetXLeft + $widthPixelsLeft)

    local widthMmLeft=$(expr $widthMm \* $leftNumerator / $leftDivisor)
    local widthMmRight=$(expr $widthMm - $widthMmLeft)

    local geometryLeft=$(printf "%d/%dx%d/%d+%d+%d" $widthPixelsLeft $widthMmLeft $heightPixels $heightMm $offsetXLeft $offsetY)
    local geometryRight=$(printf "%d/%dx%d/%d+%d+%d" $widthPixelsRight $widthMmRight $heightPixels $heightMm $offsetXRight $offsetY)

    local geometries=( $geometryLeft $geometryRight )
    echo "${geometries[*]}"

}

divide_horizontal() {
    local topNumerator=${2:-50}
    local topDivisor=${3:-100}

    # format 3840/400x2160/200+0+0
    if [[ $1 =~ ([[:digit:]]+)/([[:digit:]]+)x([[:digit:]]+)/([[:digit:]]+)\+([[:digit:]]+)\+([[:digit:]]+) ]]; then
        local widthPixels=${BASH_REMATCH[1]}
        local widthMm=${BASH_REMATCH[2]}
        local heightPixels=${BASH_REMATCH[3]}
        local heightMm=${BASH_REMATCH[4]}
        local offsetX=${BASH_REMATCH[5]}
        local offsetY=${BASH_REMATCH[6]}
    else
        echo "ERROR"
        exit 1
    fi

    local heightPixelsTop=$(expr $heightPixels \* $topNumerator / $topDivisor)
    local heightPixelsBottom=$(expr $heightPixels - $heightPixelsTop)

    local offsetYTop=$offsetY
    local offsetYBottom=$(expr $offsetYTop + $heightPixelsTop)

    local heightMmTop=$(expr $heightMm \* $topNumerator / $topDivisor)
    local heightMmBottom=$(expr $heightMm - $heightMmTop)

    local geometryTop=$(printf "%d/%dx%d/%d+%d+%d" $widthPixels $widthMm $heightPixelsTop $heightMmTop $offsetX $offsetYTop)
    local geometryBottom=$(printf "%d/%dx%d/%d+%d+%d" $widthPixels $widthMm $heightPixelsBottom $heightMmBottom $offsetX $offsetYBottom)

    local geometries=( $geometryTop $geometryBottom )
    echo "${geometries[*]}"

}

divide_three() {
    local stepOne=( $(divide_vertical "$@" 1 3) )
    local stepTwo=( $(divide_vertical "${stepOne[1]}") )
    local allThree=( ${stepOne[0]} ${stepTwo[0]} ${stepTwo[1]} )
    echo "${allThree[*]}"
}

VIRTUAL_MONITOR_KEY="hlwm"

remove_virutal_monitors() { 
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
#GEOMETRY=$(extract_geometry $@)
#echo $GEOMETRY
#THREE=( $(divide_three $GEOMETRY) )
#echo ${THREE[@]}
#create_virtual_monitors $@ "${THREE[@]}"
largest_monitor
primary_monitor
