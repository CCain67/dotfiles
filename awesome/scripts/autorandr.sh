#!/bin/bash

if xrandr | grep "DP-1-1.3 connected"; then
    xrandr --output DP-1-1.3 --primary --auto --left-of eDP-1
    xrandr --output eDP-1 --auto
else
    xrandr --output eDP-1 --auto --output DP-1-1.3 --off
fi

