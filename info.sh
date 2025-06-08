popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

nohup am start -a android.intent.action.VIEW -d https://github.com/her-boss/Integrity-Basic/blob/main/README.md >/dev/null 2>&1 & 
popup "Redirecting to Github"

exit 0
