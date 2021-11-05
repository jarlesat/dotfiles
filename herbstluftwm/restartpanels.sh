#!bash
ps -ef | grep panel.sh | grep -v "grep" | sed -r "s/hojs[[:space:]]*([[:digit:]]*).*/\1/g" | xargs -I {} kill {}
/etc/xdg/herbstluftwm/restartpanels.sh
