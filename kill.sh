#!/system/bin/sh

popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

TARGET_PROCESS="com.google.android.gms.unstable"

PID=$(pidof "$TARGET_PROCESS")

if [ -n "$PID" ]; then
    echo "- Found PID(s): $PID"
    kill -9 $PID
    echo "- Killed $TARGET_PROCESS"
    popup "GMS process killed successfully"
else
    popup "Sleeping"
fi
