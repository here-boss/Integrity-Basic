popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

su -c "pm clear com.android.vending"
su -c "pm clear com.google.android.gms"

popup " Open playstore & Check/FIX"
exit 0
