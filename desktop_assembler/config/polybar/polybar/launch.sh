#!/usr/bin/env bash

# terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# launch bar
polybar main &
echo "Main bar launched..."
polybar tray &
echo "Tray launched..."

# check if dual monitors are connected
external_monitor=$(xrandr --query | grep 'HDMI-1-0')
if [[ $external_monitor = HDMI-1-0\ connected* ]]; then
    polybar laptop &
    echo "Laptop bar launched..."
else
    echo "No dual monitor detected, laptop bar not launched..."
fi

echo "Done!"
