#!/usr/bin/env sh

# This toggles between headphones and line-out on my desktop
# https://unix.stackexchange.com/questions/726288/having-trouble-using-cli-to-switch-between-playback-devices-with-pipewire

if [[ $(pactl list | grep "Active Port: analog-output") == *"headphones"* ]]; then
    pactl set-sink-port 0 analog-output-lineout
else
    pactl set-sink-port 0 analog-output-headphones
fi
