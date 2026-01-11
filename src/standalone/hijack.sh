#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Example standalone script

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
hijack() {
	status "Performing Hijack in FreeXR Pseudo-ROM"

	# --- Invizible Pro --- (Networking Management)
	fdroidInstallApk "pan.alexander.tordnscrypt.stable_25303"
	# FIXME(Krey): Configure to use VPN Mode with Kill Switch
	# FIXME(Krey): Configure to start Tor + DNSCrypt + I2P on boot

	# --- Store --- (META Store Alternative)
	disableApp com.oculus.store # META store
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
	installApkFromURL \
	com.threethan.launcher \
	https://github.com/threethan/LightningLauncher/releases/download/9.1.0/LightningLauncher.apk \
	b3567f68f34c11e6df5699292fde82493eb85135e3066363e7fd1ef945401f24
	# FIXME(Krey): Replace the menu button in systemux to launch lightning launcher
		adb shell am start com.threethan.launcher

	# --- Tubular --- (YouTube Alternative)
	fdroidInstallApk "org.polymorphicshade.tubular_1005"

	# --- Wivrn --- (Oculus Link Alternative)
	disableApp com.meta.pclinkservice.server # Oculus Link
	installApkFromURL \
	org.meumeu.wivrn.github \
	"https://github.com/WiVRn/WiVRn/releases/download/v25.8/WiVRn-standard-release.apk" \
	9911a8f2aae92bddfe8f3bc3b70b24219105d0d0d5fe82e5206e9bb8f33d3cda

	# --- AI --- (META AI ALternative)
	# Replace META AI with Ollama .. the irony
	installApkFromURL \
	com.freakurl.apps.ollama \
	https://github.com/JHubi1/ollama-app/releases/download/1.2.0/ollama-android-v1.2.0.apk \
	6573009c09e6f8284b91607ddc81b1a3860aaa55f6c2f167217d71c3af1adf87
	# FIXME(Krey): Remove META AI app

	# --- Mediabox ---
	warn "Stremio have been disabled due to https://github.com/FreeXR/freexr-hijack/issues/2#issuecomment-3734164008, pending review.."
	# installApkFromURL \
	# com.stremio.one \
	# https://dl.strem.io/android/v1.6.13-com.stremio.one/com.stremio.one-1.6.13-4208840-arm64-v8a.apk \
	# 4eae53f4c9680a8797f745c38a202489f488da9c2bb29087f3f35bf9b2c6655c

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
	installApkFromURL \
	org.futo.voiceinput \
	https://voiceinput.futo.org/VoiceInput/standalone.apk \
	a515fec7187188f66a789ee98ca0578bd86f5299f0e0b28d861d3de2ff97a975
	fdroidInstallApk "org.woheller69.ttsengine_24"

	# --- Video Player ---
	fdroidInstallApk "dev.anilbeesetti.nextplayer_31"

	# --- Smart Phone Integration ---
	fdroidInstallApk "org.kde.kdeconnect_tp_13304"

	# --- WhoBird ---
	fdroidInstallApk "org.woheller69.whobird_46"

	# --- Calendar ---
	fdroidInstallApk "ws.xsoh.etar_51"

	# --- Remote Desktop ---
	fdroidInstallApk "com.carriez.flutter_hbb_104020002"

	# --- (Optional) META Apps
	# FIXME(Krey): Figure out how to make META apps to work in this environment e.g. sandboxing them

	# --- Other changes ---
	# FIXME(Krey): Remove META app pins from the bottom bar
	# FIXME(Krey): Remove horizon app
	# FIXME(Krey): Enable seamless multitasking
	# FIXME(Krey): Install Stremio for META Quest as replacement for META TV and Theater anywhere
	# FIXME(Krey): Make sure that META can't write killswitch in the required directory
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# sayHello # Call The Function
