popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

resetprop -p -d persist.sys.pihooks.disable.gms_props
resetprop -p -d persist.sys.pihooks.disable.gms_key_attestation_block
resetprop -p -d setprop persist.sys.pihooks.disable.gms_key_attestation_block
popup "Switched back to default settings"
