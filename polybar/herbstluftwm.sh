#!/bin/sh

hc() { "${herbstclient_command[@]:-herbstclient}" "$@" ;}

decode_color() {
    case "$@" in 
      'black') echo "#000000" ;;
      'white') echo "#FFFFFF" ;;
      'red') echo "#FF0000" ;;
      'lime') echo "#00FF00" ;;
      'blue') echo "#0000FF" ;;
      'yellow') echo "#FFFF00" ;;
      'cyan') echo "#00FFFF" ;;
      'magenta') echo "#FF00FF" ;;
      'silver') echo "#C0C0C0" ;;
      'gray') echo "#808080" ;;
      'maroon') echo "#800000" ;;
      'olive') echo "#808000" ;;
      'green') echo "#008000" ;;
      'purple') echo "#800080" ;;
      'teal') echo "#008080" ;;
      'navy') echo "#000080" ;;
      *) echo $@
    esac
}

hash herbstclient xrandr

bgcolor=$(hc get frame_border_normal_color)
bgcolor=$(decode_color "$bgcolor")
#selbg=$(hc get window_border_active_color)
selbg="red"
selbg=$(decode_color "$selbg")
selfg='#101010'

focusedTag="%%{B${selbg}}%%{F${selfg}} %s %%{F-}%%{B-}"
viewedTag="%%{B#9CA668}%%{F#141414} %s %%{F-}%%{B-}"
urgentTag="%%{B#FF0675}%%{F#141414} %s %%{F-}%%{B-}"
emptyTag="%%{F#ababab} %s %%{F-}"
notEmptyTag="%%{F#ffffff} %s %%{F-}"
viewedElsewhereTag="$empty"
focusedElsewhereTag="$empty"

print_tags() {
    printf "Xrandr '%s':" "$MONITOR"
    printf "Herbstluftwm '%d' " "$1"
	for tag in $(herbstclient tag_status "$1"); do
		name=${tag#?}
		state=${tag%$name}
        activate=$(printf '%%{A1 : herbstclient use %s : }' $name)
        activateEnd="%%{A}"
		case "$state" in
		'#')
            # the tag is viewed on the specified MONITOR and it is focused. 
            printf "$focusedTag" "$name"
			;;
		'+')
            # the tag is viewed on the specified MONITOR, but this monitor is not focused. 
#			printf "Viewed %s " "$name"
			printf "%%{A1: herbstclient use %s :}$viewedTag%%{A}" "$name" "$name"
			;;
		'!')
            # the tag contains an urgent window 
			printf "%%{A1: herbstclient use %s :}$urgentTag%%{A}" "$name" "$name"
			;;
		'.')
            # the tag is empty 
			printf "%%{A1: herbstclient use %s :}$emptyTag%%{A}" "$name" "$name"
			;;
        '-')
            # - the tag is viewed on a different MONITOR, but this monitor is not focused.
#			printf "$viewedElsewhereTag" "$name"
			printf "%%{A1: herbstclient use %s :}$viewedElsewhereTag%%{A}" "$name" "$name"
#			printf '%s %s %s' "$activate" "$name" "$activateEnd"
			;;
        ':')
            # : the tag is not empty
			printf "%%{A1: herbstclient use %s :}$notEmptyTag%%{A}" "$name" "$name"
			;;
        '%')
            # % the tag is viewed on a different MONITOR and it is focused.
			printf "%%{A1: herbstclient use %s :}$focusedElsewhereTag%%{A}" "$name" "$name"
			;;
		*)
			printf ' %s ' "$name"
		esac
	done
	printf '\n'
}


TEMP=`getopt -o f:v:u:e:n:w:g: -l focused:,viewed:,urgent:,empty:,not-empty:,viewed-elsewhere:,focused-elsewhere: -- "$@"`

eval set -- "$TEMP"

while true; do
  case "$1" in
    -f|--focused) focusedTag=$2 ; shift 2 ;;
    -v|--viewed) viewedTag=$2 ; shift 2 ;;
    -u|--urgent) urgentTag=$2 ; shift 2 ;;
    -e|--empty) emptyTag=$2 ; shift 2 ;;
    -n|--notEmpty) notEmptyTag=$2 ; shift 2 ;;
    -w|--viewedElsewhere) viewedElsewhereTag=$2 ; shift 2 ;;
    -g|--focusedElsewhere) focusedElsewhereTag=$2 ; shift 2 ;;
    -- ) shift ; break ;;
    * ) printf "Args: '$1'" ; shift ;;
  esac
done
shift $(expr $OPTIND - 1)

printf "\t\tSpecified monitor: '%s'" "$MONITOR"

geom_regex='[[:digit:]]\+x[[:digit:]]\++[[:digit:]]\++[[:digit:]]\+'
geom=$(xrandr --query | grep "^$MONITOR" | grep -o "$geom_regex")
monitor=$(herbstclient list_monitors | grep "$geom" | cut -d: -f1)

printf "\t\txrandr entry: '%s'" "$(xrandr --query | grep "^$MONITOR")"
printf "\t\tGeometry: '%s'" "$geom"

printf "\t\t"

#read_args
print_tags "$monitor"

IFS="$(printf '\t')" herbstclient --idle | while read -r hook args; do
	case "$hook" in
	tag*)
		print_tags "$monitor"
		;;
	esac
done

