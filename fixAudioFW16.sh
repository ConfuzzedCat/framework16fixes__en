#!/bin/bash

# Define paths
ORIGINAL_FILE="/usr/share/alsa/ucm2/HDA/HiFi-analog.conf"
CUSTOM_DIR="$HOME/.config/alsa/ucm2-custom"
CUSTOM_FILE="$CUSTOM_DIR/HiFi-analog.conf"

echo "--- Framework 16 UCM Transformer ---"

# 1. Create directory and copy original
mkdir -p "$CUSTOM_DIR"
cp "$ORIGINAL_FILE" "$CUSTOM_FILE"

# 2. Change the variable at the beginning of the file from "Speaker" to "Master"
# This ensures that PlaybackMixerElem etc. later use "Master".
sed -i 's/Define.spkvol "Speaker"/Define.spkvol "Master"/g' "$CUSTOM_FILE"
echo "[OK] Variable 'spkvol' switched to 'Master'."

# 3. Fix the EnableSequence for Speakers and Bass Speakers to 100%
# We locate the Switch commands and insert the Volume commands immediately afterwards.
# This ensures that the hardware is turned on, while GNOME only regulates the master.

# For the case with Bass Speaker (True branch):
sed -i "/cset \"name='Speaker Playback Switch' on\"/a \					cset \"name='Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"
sed -i "/cset \"name='Bass Speaker Playback Switch' on\"/a \					cset \"name='Bass Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"

# For the case without bass speaker (false branch / fallback):
sed -i "/cset \"name='\${var:spkvol} Playback Switch' on\"/a \					cset \"name='Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"

echo "[OK] Hardware channels (Speaker & Bass) in the EnableSequence fixed to 100%."

# 4. Final Instructions
echo ""
echo "--- Finished!---"
echo "The modified file is under: $CUSTOM_FILE"
echo ""
echo "To test them now (without restart):"
echo "sudo mount --bind $CUSTOM_FILE $ORIGINAL_FILE"
echo "systemctl --user restart pipewire wireplumber"
echo ""
echo "To make it permanent, paste this line in /etc/fstab:"
echo "$CUSTOM_FILE $ORIGINAL_FILE none bind,defaults 0 0"
