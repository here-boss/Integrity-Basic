popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

nohup am start -a android.intent.action.VIEW -d https://t.me/IntegrityBasic >/dev/null 2>&1 & 
popup "Report your problem here"

exit 0
