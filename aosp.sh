#!/system/bin/sh

SOURCE="/data/adb/modules/Integrity-Basic-Logs/keybox.xml"
DEST_DIR="/data/adb/tricky_store"
DEST_FILE="$DEST_DIR/keybox.xml"
BACKUP_FILE="$DEST_DIR/keybox.xml.md"

BOSS() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

# Ensure destination directory exists
mkdir -p "$DEST_DIR"

# backup if already exists 
if [ -f "$DEST_FILE" ]; then
  mv -f "$DEST_FILE" "$BACKUP_FILE"
fi

# Copy aosp keybox
cp -f "$SOURCE" "$DEST_FILE"
chmod 644 $DEST_FILE
MEOW "Switched to AOSP keybox"