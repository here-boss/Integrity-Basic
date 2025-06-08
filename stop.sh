#!/system/bin/sh

file="/sdcard/stop"
shamiko="/data/adb/shamiko/whitelist"
nohello="/data/adb/nohello/whitelist"

BOSS() {
  am start -a android.intent.action.MAIN -e boss "$1" -n boss.loader/.MainActivity &>/dev/null
  sleep 0.5
}

# Create the stop file
if ! touch "$file"; then
  BOSS "Failed to create stop file"
  exit 1
fi

[ -f "$shamiko" ] && {
  rm -f "$shamiko"
  BOSS "Shamiko auto-whitelist stopped"
}

[ -f "$nohello" ] && {
  rm -f "$nohello"
  BOSS "NoHello auto-whitelist stopped"
}

exit 0