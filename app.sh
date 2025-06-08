#!/system/bin/sh

L="/data/adb/Integrity-Basic-Logs/risky_apps.log"
TIME=$(date "+%Y-%m-%d %H:%M:%S")
Q="------------------------------------------"
R="════════════════════════════════"

log() {
    echo -e "$1" | tee -a "$L"
}

BOSS() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

# Start logging
echo -e "$Q" >> "$L"
echo -e " - INTEGRITY-BASIC RISKY APPS DETECTION | $TIME " >> "$L"
echo -e "$Q\n" >> "$L"

# Risky Apps Detection
log "- Risky Apps Detection"
RISKY_APPS="com.rifsxd.ksunext:KernelSU Next
me.weishu.kernelsu:KernelSU
com.google.android.hmal:Hide_My_Applist
me.twrp.twrpapp:TWRP
com.termux:Termux
com.slash.batterychargelimit:Battery_Charging_Limit
io.github.vvb2060.keyattestation:Key_Attestation
io.github.muntashirakon.AppManager:App_Manager
io.github.vvb2060.mahoshojo:Momo
com.reveny.nativecheck:Native_Detector
icu.nullptr.nativetest:NativeTest
io.github.huskydg.memorydetector:Memory_Detector
org.akanework.checker:Checker
icu.nullptr.applistdetector:Applist_Detectot
io.github.rabehx.securify:Securify
krypton.tbsafetychecker:TB_Checker
me.garfieldhan.holmes:Holmes
com.byxiaorun.detector:Ruru
com.kimchangyoun.rootbeerFresh.sample:Root_Beer"

FOUND_APPS=""

for entry in $RISKY_APPS; do
    PKG=$(echo "$entry" | cut -d':' -f1)
    NAME=$(echo "$entry" | cut -d':' -f2)
    
    if pm list packages | grep -q "$PKG"; then
        FOUND_APPS="$FOUND_APPS\n$NAME ($PKG)"
    fi
done

if [ -n "$FOUND_APPS" ]; then
    echo "Detected Risky Apps ($(echo -e "$FOUND_APPS" | wc -l))"
    log "   └─ Found:\n$FOUND_APPS"
    log "$Q"
else
    log "   └─ Not Found"
fi

log "- Detection Complete!\n"
log " "
log "TIP: Use H.M.A to hide them"
log " "
echo -e "$R" >> "$L"
BOSS "Log saved to $L"