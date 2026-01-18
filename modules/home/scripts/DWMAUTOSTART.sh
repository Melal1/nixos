#!/usr/bin/env bash


vicinae server &
xrandr \
  --output HDMI-A-0 --mode 1920x1080 --rate 75 --pos 0x0 \
  --output DisplayPort-0 --mode 2560x1440 --rate 180 --pos 1920x0 --primary &

xset r 200 30 &

