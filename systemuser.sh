#!/bin/sh
TARGET='/data/adb/tricky_store/target.txt'
TEE_STATUS='/data/adb/tricky_store/tee_status'

popup() {
    am start -a android.intent.action.MAIN -e boss "$@" -n boss.loader/.MainActivity > /dev/null
    sleep 0.5
}

# Ensure TrickyStore directory exists
if [ ! -d "/data/adb/tricky_store" ]; then
    echo "- Please install Trickystore Module"
    nohup am start -a android.intent.action.VIEW -d https://github.com/5ec1cff/TrickyStore/releases >/dev/null 2>&1 & 
    popup "Redirecting to Github"
    exit 1
fi

# Ensure the target file directory exists
mkdir -p /data/adb/tricky_store

# Remove the target.txt file if it exists
[ -f "$TARGET" ] && rm "$TARGET"

# Read teeBroken value
teeBroken="false"
if [ -f "$TEE_STATUS" ]; then
    teeBroken=$(grep -E '^teeBroken=' "$TEE_STATUS" | cut -d '=' -f2 2>/dev/null || echo "false")
fi

# Start writing the target list
echo "# Last updated on $(date '+%A %d/%m/%Y %I:%M:%S%p')" > "$TARGET"
echo "#" >> "$TARGET"
echo "android" >> "$TARGET"
echo "com.android.vending!" >> "$TARGET"
echo "com.google.android.gms!" >> "$TARGET"
echo "com.reveny.nativecheck!" >> "$TARGET"
echo "io.github.vvb2060.keyattestation!" >> "$TARGET"
echo "io.github.vvb2060.mahoshojo" >> "$TARGET"
echo "icu.nullptr.nativetest" >> "$TARGET"
popup "This may take a while, have patience"
echo "- Updating target list as per your TEE status"

# Function to add package names to target list
add_packages() {
    pm list packages "$1" | cut -d ":" -f 2 | while read -r pkg; do
        if [ -n "$pkg" ] && ! grep -q "^$pkg" "$TARGET"; then
            if [ "$teeBroken" = "true" ]; then
                echo "$pkg!" >> "$TARGET"
            else
                echo "$pkg" >> "$TARGET"
            fi
        fi
    done
}

# Add user apps
add_packages "-3"

# Add system apps
add_packages "-s"

# Display the result
echo "- Updating target list"
echo " "
echo "-----------------------------------------------"
echo "  All System & User Apps with TEE support"
echo "-----------------------------------------------"
cat "$TARGET"
popup "Updated target.txt"

su -c "am force-stop com.google.android.gms.unstable"
su -c "am force-stop com.android.vending"

exit 0
