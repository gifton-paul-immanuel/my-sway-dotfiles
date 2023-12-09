#!/usr/bin/bash

killall -q swaybg
while pgrep -x swaybg >/dev/null; do sleep 1; done
swaybg -i $(find ~/.config/sway/wallpapers/* | shuf -n1) -m fill