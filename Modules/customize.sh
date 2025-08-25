#!/bin/sh

# Set to true to enable late_start service mode
LATESTARTSERVICE=true

# --- Module and Device Info Display ---
ui_print "------------------------------------"
ui_print "		Systemless Host + AdAway	  "
ui_print "------------------------------------"
ui_print "         By: Kanagawa Yamada		  "
ui_print "------------------------------------"
ui_print "	   Big Thanks For: @symbuzzer	  "
ui_print "------------------------------------"
ui_print " "
sleep 1.5

ui_print "------------------------------------"
ui_print "            DEVICE INFO             "
ui_print "------------------------------------"
ui_print "DEVICE : $(getprop ro.build.product) "
ui_print "MODEL : $(getprop ro.product.model) "
ui_print "MANUFACTURE : $(getprop ro.product.system.manufacturer) "
ui_print "PROC : $(getprop ro.product.board) "
ui_print "CPU : $(getprop ro.hardware) "
ui_print "ANDROID VER : $(getprop ro.build.version.release) "
ui_print "KERNEL : $(uname -r) "
ui_print "RAM : $(free | grep Mem |  awk '{print $2}') "
ui_print " "
sleep 1.5

ui_print "------------------------------------"
ui_print "            MODULE INFO             "
ui_print "------------------------------------"
ui_print "Name : Systemless Host + AdAway"
ui_print "Version : 1.0"
ui_print "Support Root : Magisk / KSU / KSUN / APatch"
ui_print " "
sleep 1.5

# --- Systemless Host Installation ---
ui_print "     Installing Systemless Host	  "
ui_print " "
sleep 1.5

# Set the PATH for root executables
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH

# prevent installation on magic mount managers
if ! grep -q sdcardfs /proc/filesystems >/dev/null 2>&1; then
	# test for magic mount
	if [ "$KSU_MAGIC_MOUNT" = "true" ] || [ "$APATCH_BIND_MOUNT" = "true" ] || { [ -f /data/adb/magisk/magisk ] && [ -z "$KSU" ] && [ -z "$APATCH" ]; }; then
		ui_print '[!] This module is not compatible to magic mount managers!'
    abort "Tip: Enable OverlayFS in Managers settings"
	fi
fi

# Create module directories and files for systemless hosts
mkdir -p "$MODPATH/system/etc"
busybox chcon --reference"/system" "$MODPATH/system"
cat /system/etc/hosts > "$MODPATH/system/etc/hosts"
busybox chcon --reference"/system/etc/hosts" "$MODPATH/system/etc/hosts"
chmod 644 "$MODPATH/system/etc/hosts"
mkdir "$MODPATH/worker"
touch "$MODPATH/skip_mount"

# --- AdAway Installation ---
ui_print " 			Installing AdAway		"
ui_print " "
sleep 1

# Get the latest AdAway download URL using wget
ui_print "- Fetching the latest AdAway APK URL..."
# The `wget -q -O -` command downloads the content to standard output, simulating curl's behavior
ADAWAY_URL=$(wget -q -O - https://api.github.com/repos/AdAway/AdAway/releases/latest | grep "browser_download_url.*\.apk" | cut -d '"' -f 4)

# Abort if the URL couldn't be fetched
if [ -z "$ADAWAY_URL" ]; then
  ui_print " "
  ui_print "[!] ERROR: Failed to get AdAway download URL."
  ui_print "[!] Please check your internet connection and try again."
  abort "Aborting installation!"
fi

# Define the temporary download path for the APK
APK_PATH="/data/local/tmp/AdAway.apk"

# Download the APK using wget
ui_print "- Downloading AdAway..."
# The `wget -O` command saves the download to a specific file path
wget -O $APK_PATH "$ADAWAY_URL"

# Check if the download command failed
if [ $? -ne 0 ]; then
  ui_print " "
  ui_print "[!] ERROR: AdAway APK download failed!"
  # Clean up any partial download
  [ -f "$APK_PATH" ] && rm -f "$APK_PATH"
  abort "Aborting installation!"
else
  ui_print "- Download complete."
  ui_print " "
fi

# Install the APK using the package manager
ui_print "- Installing AdAway via package manager..."
pm install "$APK_PATH" >/dev/null 2>&1

# Check if the installation failed
if [ $? -ne 0 ]; then
  ui_print " "
  ui_print "[!] WARNING: AdAway installation failed."
  ui_print "    This could be due to your device's SELinux policy."
  ui_print " "
else
  ui_print "- Installation successful."
  ui_print " "
  # Clean up the downloaded APK only on successful install
  ui_print "- Cleaning up temporary files..."
  rm -f "$APK_PATH"
fi

# --- End of Script ---