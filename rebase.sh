#!/system/bin/sh
logdir=/data/adb/Integrity-Basic-Logs
log=$logdir/rebase.log

# Logger
boss() {
    echo "$1" | tee -a "$log"
}

# Create log directory 
mkdir -p $logdir
touch $log

OLD_PATHS="
/data/adb/modules/Integrity-Basic
/data/adb/modules_update/Integrity-Basic
/data/adb/Integrity-Basic
"

boss "- Checking for old Integrity-Basic files"
boss " "

found=false

for path in $OLD_PATHS; do
  if [ -e "$path" ]; then
    boss "- Removing: $path"
    rm -rf "$path"
    found=true
  fi
done

 if $found; then
   boss " "
  boss "========================================"
  boss "- Old Integrity-Basic installation detected"
   boss "- Performing clean-up for safe update"
   boss " "
   boss "- WHY CLEAN INSTALLATION IS REQUIRED:"
   boss "+ Module internals & structure updated"
   boss "+ Old leftovers can break functionality"
   boss "- Clean install ensures full compatibility"
   boss
   boss "REBOOT IS MANDATORY to apply changes"
   boss "========================================"
   boss " "
   boss "- Clean-up complete."
   for i in $(seq 10 -1 1); do
    boss "- Rebooting in $i seconds..."
   sleep 1
   done
   rm -rf /data/adb/modules_update/integrity_basic # Delete extracted files
   sleep 1
   boss "- Rebooting now!"
   reboot
   exit 1
 else
   boss "- No old Integrity-Basic files found"
   boss "- Proceed with installing the latest version"
   boss " "
fi
exit 0