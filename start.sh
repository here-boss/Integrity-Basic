#!/system/bin/sh

file="/sdcard/stop"
shamiko="/data/adb/shamiko/whitelist"
nohello="/data/adb/nohello/whitelist"

BOSS() {
  am start -a android.intent.action.MAIN -e boss "$1" -n boss.loader/.MainActivity &>/dev/null
  sleep 0.5
}

# Remove the stop file
[ -f "$file" ] && rm -f "$file" && BOSS "Auto Whitelist Mode enabled"

# Restore Shamiko whitelist if parent dir exists
[ -d "$(dirname "$shamiko")" ] && [ ! -f "$shamiko" ] && touch "$shamiko"

# Restore NoHello whitelist if parent dir exists
[ -d "$(dirname "$nohello")" ] && [ ! -f "$nohello" ] && touch "$nohello"

exit 0