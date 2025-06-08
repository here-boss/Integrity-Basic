BOSS() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

nohup am start -a android.intent.action.VIEW -d https://android.googleapis.com/attestation/status >/dev/null 2>&1 &
BOSS "Redirecting to Google Revoked List"

exit 0