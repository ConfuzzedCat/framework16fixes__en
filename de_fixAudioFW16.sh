#!/bin/bash

# Pfade definieren
ORIGINAL_FILE="/usr/share/alsa/ucm2/HDA/HiFi-analog.conf"
CUSTOM_DIR="$HOME/.config/alsa/ucm2-custom"
CUSTOM_FILE="$CUSTOM_DIR/HiFi-analog.conf"

echo "--- Framework 16 UCM Transformer ---"

# 1. Verzeichnis erstellen und Original kopieren
mkdir -p "$CUSTOM_DIR"
cp "$ORIGINAL_FILE" "$CUSTOM_FILE"

# 2. Die Variable am Anfang der Datei von "Speaker" auf "Master" ändern
# Dies sorgt dafür, dass PlaybackMixerElem etc. später "Master" nutzen.
sed -i 's/Define.spkvol "Speaker"/Define.spkvol "Master"/g' "$CUSTOM_FILE"
echo "[OK] Variable 'spkvol' auf 'Master' umgestellt."

# 3. Die EnableSequence für Speaker und Bass Speaker auf 100% fixieren
# Wir suchen die Switch-Befehle und fügen die Volume-Befehle direkt danach ein.
# Das sorgt dafür, dass die Hardware aufgedreht wird, während GNOME nur den Master regelt.

# Für den Fall mit Bass Speaker (True-Zweig):
sed -i "/cset \"name='Speaker Playback Switch' on\"/a \					cset \"name='Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"
sed -i "/cset \"name='Bass Speaker Playback Switch' on\"/a \					cset \"name='Bass Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"

# Für den Fall ohne Bass Speaker (False-Zweig / Fallback):
sed -i "/cset \"name='\${var:spkvol} Playback Switch' on\"/a \					cset \"name='Speaker Playback Volume' 100%\"" "$CUSTOM_FILE"

echo "[OK] Hardware-Kanäle (Speaker & Bass) in der EnableSequence auf 100% fixiert."

# 4. Abschluss-Instruktionen
echo ""
echo "--- Fertig! ---"
echo "Die modifizierte Datei liegt unter: $CUSTOM_FILE"
echo ""
echo "Um sie jetzt zu testen (ohne Neustart):"
echo "sudo mount --bind $CUSTOM_FILE $ORIGINAL_FILE"
echo "systemctl --user restart pipewire wireplumber"
echo ""
echo "Um es permanent zu machen, füge diese Zeile in /etc/fstab ein:"
echo "$CUSTOM_FILE $ORIGINAL_FILE none bind,defaults 0 0"
