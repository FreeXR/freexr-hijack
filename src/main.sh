#!/usr/bin/env sh

### DO NOT RUN THIS SCRIPT! EVALUATION AND DEVELOPMENT ONLY! ###

# FreeXR Hijack Script of the META Quest 3 (Eureka) Device, replacing as many packages as possible with open-source alternativesi and removing META/Oculus apps until we figure out how to unlock the bootloader
#
# Tested on Eureka v76, use caution for other firmware versions
#
# Instructions:
# 0.0. Extract META Access Token, Oculus Access Token and deviceKey from horizon app using root on your android phone (no idea how rn)
# 0. Get an Android Phone or Emulator and install Private Quest App (https://xdaforums.com/t/app-5-0-private-quest-vr-headset-management-tool.4695491). We assume private quest 1.3 for this tutorial
# 0.1. Get an ADB-cabable system, ideally linux with adb package
# 1. On Eureka: POWER+VOL_DOWN until the device turns off and bootloader menu appears, then perform factory reset (WARNING: YOU WILL LOSE ALL YOUR DATA!)
# 2. Once eureka boots up, connect to it via private quest:
# 2.1. Private Quest -> Init -> Set DeviceKey
# 2.2. Private Quest -> Config -> Disable OTA -> Get, then turn the toggle to the OFF position.
# 2.3. Private Quest -> Control -> Developer mode -> Get, then turn to ON position
# 2.4. Private Quest -> Control -> ADB -> Get, then turn to ON position
# 2.5. Private Quest -> Init -> Set Oculus token
# 2.6. Private Quest -> Init -> Set Meta token
# 2.7. Private Quest -> Init -> Skip NUX
# 3. The device is now in de-META and de-oculed state as the Oculus and Meta tokens are not set.
# 4. Connect eureka to your computer with ADB and in eureka set always trust
# 5. Run this script
#
# Action plan:
# 0. Disable OTA
# 1. Remove all META/Oculus apps to the point where we have bare minimum device
# 2. Install alternatives
# 3. Sanitize Companion Server
# 4. Include neo store as replacement to meta store including sidequest repositories
# 5. Replace the Library app (launcher) with lightning launcher

set -e # Exit on false return

# shellcheck source=./lib/common.sh
. ./src/lib/common.sh # Source Common Libraries

# Process Arguments
while [ "$#" -gt 0 ]; do case "$1" in
	"-d"|"--debug") DEBUG=1 ;;
	"--HIJACK")
		# --- Invizible Pro --- (Networking Management)
		fdroidInstallApk "pan.alexander.tordnscrypt.stable_25303"
		# FIXME(Krey): Configure to use VPN Mode with Kill Switch
		# FIXME(Krey): Configure to start Tor + DNSCrypt + I2P on boot

		# --- Store --- (META Store Alternative)
		# Neo Store
		fdroidInstallApk "com.machiav3lli.fdroid_1104"
		# FIXME(Krey): Configure Neo Store to use Tor
		# FIXME(Krey): Configure Neo Store to use our f-droid repositories
		# FIXME(Krey): Ask SideQuest to provide f-droid repository for their apps
		# Itch.io (Mitch)
		fdroidInstallApk "ua.gardenapple.itchupdater_20303"
		# GPlay
		fdroidInstallApk "com.aurora.store_70"

		# --- Lightning Launcher --- (Library Alternative)
		# Install Lightning Launcher
		installApkFromURL "https://github.com/threethan/LightningLauncher/releases/download/9.1.0/LightningLauncher.apk" "com.threethan.launcher.apk"
		# FIXME(Krey): Replace the menu button in systemux to launch lightning launcher
		adb shell am start com.threethan.launcher # Open The Launcher to make it accessible

		# --- Tubular --- (YouTube Alternative)
		fdroidInstallApk "org.polymorphicshade.tubular_1005"

		# --- Wivrn --- (Oculus Link Alternative)
		installApkFromURL "https://github.com/WiVRn/WiVRn/releases/download/v25.8/WiVRn-standard-release.apk" "org.meumeu.wivrn.github.apk"

		# --- AI --- (META AI ALternative)
		# Replace META AI with Ollama .. the irony
		installApkFromURL "https://github.com/JHubi1/ollama-app/releases/download/1.2.0/ollama-android-v1.2.0.apk" "com.freakurl.apps.ollama.apk"

		# --- Maps ---
		fdroidInstallApk "net.osmand.plus_510703"

		# --- App Manager ---
		fdroidInstallApk "io.github.muntashirakon.AppManager_445"

		# --- Web Browser ---
		fdroidInstallApk "org.mozilla.fennec_fdroid_1410220"

		# --- E-Mail ---
		fdroidInstallApk "com.fsck.k9_39025"

		# --- File Browser ---
		fdroidInstallApk "me.zhanghai.android.files_39"

		# --- Voice Assistant ---
		fdroidInstallApk "org.stypox.dicio_16"
		# FIXME(Krey): Once requested it turns the EmuShell into an infinite loading bar
		installApkFromURL "https://voiceinput.futo.org/VoiceInput/standalone.apk" "org.futo.voiceinput.apk"
		fdroidInstallApk "org.woheller69.ttsengine_24"

		# --- Video Player ---
		fdroidInstallApk "dev.anilbeesetti.nextplayer_31"

		# --- Smart Phone Integration ---
		fdroidInstallApk "org.kde.kdeconnect_tp_13304"

		# --- WhoBird ---
		fdroidInstallApk "org.woheller69.whobird_46"

		# --- Calendar ---
		fdroidInstallApk "ws.xsoh.etar_51"

		# --- (Optional) META Apps
		# FIXME(Krey): Figure out how to make META apps to work in this environment e.g. sandboxing them

		# --- Other changes ---
		# FIXME(Krey): Remove META app pins from the bottom bar
		# FIXME(Krey): Remove horizon app
		# FIXME(Krey): Enable seamless multitasking
		# FIXME(Krey): Install Stremio for META Quest as replacement for META TV and Theater anywhere
		# FIXME(Krey): Make sure that META can't write killswitch in the required directory
	;;
esac; shift; done
