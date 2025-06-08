#!/system/bin/sh
MODDIR=${0%/*}
mona01="/data/adb/modules/tricky_store"
mona02="/data/adb/tricky_store"
mona03="$mona02/.k"
mona04="$mona02/keybox.xml"
mona05="$mona02/keybox.xml.bak"
mona06="/data/adb/Integrity-Basic-Logs"
mona07="$mona06/Installation.log"
mona08="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNv"
mona09='curl busybox magisk apatch toybox wget'
mona10="/data/adb/modules_update/integrity_basic"
mona11="/data/adb/susfs4ksu"
mona12="$mona11/sus_path.txt"
mona13="bnRlbnQuY29tL01lb3dEdW1wL0ludGVncml0eS1Cb3gv"
mona14="/system/product/app/BossLoader/BossLoader.apk"
mona15="com.helluva.product.integrity"
mona16="$mona02/target.txt"
mona17="/data/adb/modules/playintegrityfix"
mona18="$mona17/module.prop"
mona19="2025-05-05"
mona20="YWxwaGEvRFVNUC9idWZmZXIudGFy"
mona21="$mona02/security_patch.txt"
mona22="$mona10/hashes.txt"
mona23="$mona10/customize.sh"
mona24="$mona02/tee_status"
mona25="$mona03.d"

chmod +x "$mona10/rebase.sh"
sh "$mona10/rebase.sh"

# Logger
boss() {
    echo "$1" | tee -a "$mona07"
}

# Create log directory 
mkdir -p $mona06
touch $mona06/Installation.log

# Internet check function
internet() {
    local _hosts="8.8.8.8 1.1.1.1 google.com"
    local _max_retries=3
    local _attempt=1

    while [ $_attempt -le $_max_retries ]; do
        for host in $_hosts; do
            if ping -c 1 -W 1 "$host" >/dev/null 2>&1; then
                boss "- Internet connection is available (Attempt $_attempt/$_max_retries)"
                return 0
            fi
        done

        boss "- Internet not available (Attempt $_attempt/$_max_retries)"
        _attempt=$(( _attempt + 1 ))
        sleep 1
    done

    boss "- No / Poor internet connection after $_max_retries attempts. Exiting..."
    return 1
}

# BusyBox detector 
busybox_finder() {
    for path in /data/adb/modules/busybox-ndk/system/*/busybox \
                /data/adb/ksu/bin/busybox \
                /data/adb/ap/bin/busybox \
                /data/adb/magisk/busybox; do
        if [ -x "$path" ]; then
            boss "- Using BusyBox from $path" >&2  # Redirect log to stderr
            echo "$path"  # Path only to stdout
            return 0
        fi
    done
    boss "No BusyBox executable found in candidate paths" >&2
    echo ""  # Output empty string so $BUSYBOX is still defined
    return 0
}

# TEE status [!]
tee_detector() {
    pm list packages "$1" | cut -d ":" -f 2 | while read -r pkg; do
        if [ -n "$pkg" ] && ! grep -q "^$pkg" "$mona16"; then
            if [ "$teeBroken" = "true" ]; then
                echo "$pkg!" >> "$mona16"
            else
                echo "$pkg" >> "$mona16"
            fi
        fi
    done
}

gajar_ka_halwa() {
  _buf=0
  _bits=0
  while IFS= read -r -n1 c; do
    case "$c" in
      [A-Z]) v=$(printf '%d' "'$c"); v=$((v - 65)) ;;
      [a-z]) v=$(printf '%d' "'$c"); v=$((v - 71)) ;;
      [0-9]) v=$(printf '%d' "'$c"); v=$((v + 4)) ;;
      '+') v=62 ;;
      '/') v=63 ;;
      '=') break ;;
      *) continue ;;
    esac
    _buf=$((_buf << 6 | v))
    _bits=$((_bits + 6))
    if [ $_bits -ge 8 ]; then
      _bits=$((_bits - 8))
      out=$(( (_buf >> _bits) & 0xFF ))
      printf \\$(printf '%03o' "$out")
    fi
  done
}

# Pop-up function 
popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity &>/dev/null
    sleep 0.5
}

# Tampering detector 
integrity() {
    local nibba="$1"
    local nibbi="$2"

    if [ ! -f "$nibba" ]; then
        boss "- Error: Hash file not found at $nibba"
        return 1
    fi

    if ! . "$nibba"; then
        boss "- Error: Failed to source hash file at $nibba"
        return 1
    fi

    if [ -z "$installer" ]; then
        boss "- Error: Sinstaller not defined in $nibba"
        return 1
    fi

    local sum
    sum=$(md5sum "$nibbi" 2>/dev/null | awk '{print $1}')

    if [ -z "$sum" ]; then
        boss "- Error calculating checksum for $nibbi"
        return 1
    fi

    if [ "$sum" != "$installer" ]; then
        boss "- Tampering detected in module script!"
        boss "- Expected: $installer"
        boss "- Found:    $sum"
        return 1
    fi

    boss "- File integrity check passed"
    return 0
}

if ! internet; then
    exit 1
fi

BUSYBOX=$(busybox_finder)

# Notify busybox path
echo "- Busybox set to '$BUSYBOX'"

#Refresh the fp using PIF module 
boss " "
boss "- Scanning Play Integrity Fix"
if [ -d "$mona17" ] && [ -f "$mona18" ]; then
    if grep -q "name=Play Integrity Fix" "$mona18"; then
        boss "- Detected: PIF by chiteroman"
        boss "- Refreshing fingerprint using chiteroman's module"
        boss " "
        sh "$mona17/action.sh" > /dev/null 2>&1
        popup "Updated"
        boss " "
    elif grep -q "name=Play Integrity Fork" "$mona18"; then
        boss "- Detected: PIF by osm0sis"
        boss "- Refreshing fingerprint using osm0sis's module"
        sh "$mona17/autopif2.sh" > /dev/null 2>&1
        popup "Fingerprint has been updated"
        boss " "
        
    fi
fi

integrity "$mona22" "$mona23" || exit 1

# Install apk to generate pop-up messages 
boss "- Activating IntegrityBasic Assistant"
if pm install "$MODPATH/$mona14" &>/dev/null; then
    popup "IntegrityBasic Assistant is Online"
else
boss "- Signature mismatched, Uninstalling."
pm uninstall boss.loader
boss "- Updating IntegrityBasic Assistant"
pm install "$MODPATH/system/product/app/BossLoader/BossLoader.apk" >> /dev/null
sleep 3
popup "IntegrityBasic Assistant is Online"
fi
boss " "
sleep 1

# Disable ximi PIF if exists 
if su -c pm list packages | grep -q "eu.xiaomi.module.inject"; then
    boss "- Disabling spoofing for EU ROMs"
    su -c pm disable eu.xiaomi.module.inject &>/dev/null
fi

# Disable HelluvaOs pif if exists 
if pm list packages | grep -q "$mona15"; then
    pm disable-user $mona15
    boss "- Disabled Hentai PIF"
fi
sleep 1

# SusFS related function 
boss "- Performing internal checks"
boss "- Checking for susFS"
if [ -f "$mona12" ]; then
    boss "- SusFS is installed"
    boss " "
    popup " Let Me Take Care"

touch "$mona12"
chmod 644 "$mona12"

echo "----------------------------------------------------------" >> "$mona07"
echo "Logged on $(date '+%A %d/%m/%Y %I:%M:%S%p')" >> "$mona07"
echo "----------------------------------------------------------" >> "$mona07"
echo " " >> "$mona07"

if [ ! -w "$mona12" ]; then
    boss "- $mona12 is not writable. Please check file permissions."
    exit 0
fi

boss "- Adding necessary paths to sus list"
> "$mona12"

for path in \
    "/system/addon.d" \
    "/sdcard/TWRP" \
    "/sdcard/Fox" \
    "/vendor/bin/install-recovery.sh" \
    "/system/bin/install-recovery.sh"; do
    echo "$path" >> "$mona12"
#    boss "- Path added: $path"
done

boss "- Scanning system for Custom ROM detection.."
popup "This'll take a few seconds, have patience "
for dir in /system /product /data /vendor /etc /root; do
#    boss "- Searching in: $dir... "
    find "$dir" -type f 2>/dev/null | grep -i -E "lineageos|crdroid|gapps|evolution|magisk" >> "$mona12"
done

chmod 644 "$mona12"
boss "- Scan complete. & saved to sus list "

popup "Make it SUS"
boss " "
else
    boss "- SusFS not found. Skipping file generation"
    boss " "
fi

# TrickyStore related functions. Skip if TS isn't installed
 if [ -d "$mona01" ]; then

   [ -s "$mona04" ] && cp -f "$mona04" "$mona05"

   X=$(printf '%s%s%s' "$mona08" "$mona13" "$mona20" | tr -d '\n' | gajar_ka_halwa)

   PATH="${B%/*}:$PATH"

   X=$(printf '%s%s%s' "$mona08" "$mona13" "$mona20" | tr -d '\n' | gajar_ka_halwa)

   if [ -n "$BUSYBOX" ] && "$BUSYBOX" wget --help >/dev/null 2>&1; then
     "$BUSYBOX" wget -q --no-check-certificate -O "$mona03" "$X"
   elif command -v wget >/dev/null 2>&1; then
     wget -q --no-check-certificate -O "$mona03" "$X"
   elif command -v curl >/dev/null 2>&1; then
     curl -fsSL --insecure "$X" -o "$mona03"
   else
     boss "- No supported downloader found (BusyBox/wget/curl)" >&2
     exit 7
   fi

   [ -s "$mona03" ] || exit 3

   if ! base64 -d "$mona03" > "$mona25" 2>/dev/null; then
   rm -f "$mona03"
   exit 4
   fi

   [ -s "$mona25" ] && cp -f "$mona25" "$mona04"

   s=$(for x in $mona09; do printf 's/%s//g;' "$x"; done)
   SED_BIN="$(command -v sed)"
   $SED_BIN "$s" "$mona25" > "$mona04"

   rm -f "$mona03" "$mona25"

   if [ ! -s "$mona04" ]; then
     if [ -s "$mona05" ]; then
    mv -f "$mona05" "$mona04"
    boss "- Update failed, Restoring backup"
   else
    boss "- Update failed. No backup available"
  fi
  exit 5
else
  popup "You're good to go"
fi


   if [ -f "$mona16" ]; then
     rm -f "$mona16"
   fi

   teeBroken="false"
   if [ -f "$mona24" ]; then
     teeBroken=$( { grep -E '^teeBroken=' "$mona24" | cut -d '=' -f2; } 2>/dev/null || echo "false" )
   fi

   boss "- Updating target list as per your TEE status"

   {
     echo "# Last updated on $(date '+%A %d/%m/%Y %I:%M:%S%p')"
     echo "#"
     echo "android"
     echo "com.android.vending!"
     echo "com.google.android.gms!"
     echo "com.reveny.nativecheck!"
     echo "io.github.vvb2060.keyattestation!"
     echo "io.github.vvb2060.mahoshojo"
     echo "icu.nullptr.nativetest"
   } > "$mona16"

    tee_detector "-3"
    tee_detector "-s"
   boss "- Target list has been updated "

   if [ ! -f "$mona21" ]; then
     echo "all=$mona19" > "$mona21"
   fi

   boss "- TrickyStore spoof applied "
   chmod 644 "$mona16"
   boss " "
   sleep 1
 else
   boss "- Skipping TS related functions, TrickyStore is not installed"
 fi

# Remove openssl binaries & logs generate by any previous version of module (if exists)
chmod +x "$mona10/cleanup.sh"
sh "$mona10/cleanup.sh"

boss "- Smash The Action/WebUI After Rebooting"
boss " "
boss " "
boss "         ••• Installation Completed ••• "
boss " "
boss " " 

# Redirect Module Release Source and Finish Installation
nohup am start -a android.intent.action.VIEW -d https://t.me/IntegrityBasic >/dev/null 2>&1 &
popup "This module was modded by hereBoss"
exit 0
# End Of File
