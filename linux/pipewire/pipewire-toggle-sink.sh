#!/usr/bin/env sh

# This toggles between headphones and line-out on my desktop
# https://unix.stackexchange.com/questions/726288/having-trouble-using-cli-to-switch-between-playback-devices-with-pipewire
# https://unix.stackexchange.com/questions/65246/change-pulseaudio-input-output-from-shell

SINK1="alsa_output.pci-0000_0b_00.4.analog-stereo"
SINK2="alsa_output.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.analog-stereo-output"

if [[ $(pactl get-default-sink | grep "$SINK1") == *"$SINK1"* ]]; then
    pactl set-default-sink $SINK2
else
    pactl set-default-sink $SINK1
fi
