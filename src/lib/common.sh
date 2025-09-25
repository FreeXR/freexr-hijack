#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

set -e # Exit on False

# --- Helpers ---
die() { printf "FATAL: %s\n" "$2"; exit ;}
warn() { printf "WARN: %s\n" "$1" ;}
status() { printf "STATUS: %s\n" "$1" ;}
fixme() { printf "FIXME: %s\n" "$1"; exit 23 ;}
debug() { [ -z "$DEBUG" ] || printf "DEBUG: %s\n" "$1" ;}
success() { printf "OK: %s\n" "$1"; return 0 ;}

# --- Pulse Check ---
adb shell return 0 || die 1 "Device is not connected and authentificated with adb server"

# --- Exports ---
projectName="FreeXR-Hijack"

# shellcheck disable=SC2034 # Optional Variable
gitRoot="$(git rev-parse --show-toplevel || true)"

projectCacheDir="$HOME/.cache/$projectName"

# shellcheck disable=SC2155 # Optional Variable
export productModel="$(adb shell getprop ro.product.model)"
	status "Product Model Detected: $productModel"

# shellcheck disable=SC2155 # Optional Variable
export productManufacturer="$(adb shell getprop ro.product.manufacturer)"
	status "Product Manufacturer Detected: $productManufacturer"

# shellcheck disable=SC2155 # Optional Variable
export productName="$(adb shell getprop ro.product.name)"
	status "Product Name Detected: $productName"

# shellcheck disable=SC2155 # Optional Variable
export productDevice="$(adb shell getprop ro.product.device)"
	status "Product Device Detected: $productDevice"

# --- Init ---
[ -d "$HOME" ] || die 1 "Your HOME Directory does not exist, exitting for safety"
[ -d "$HOME/.cache" ] || mkdir "$HOME/.cache"
[ -d "$HOME/.cache/$projectName" ] || mkdir "$HOME/.cache/$projectName"

# --- Functions ---
isApkNameInstalled() {
	[ "$(adb shell pm list packages -a | grep "$apkName" || true)" = "" ] || return 0
	return 1
}

# Disable Package
disableApp() {
	[ -n "$(adb shell pm list packages -d | grep "$1" || true)" ] || {
		status "Disabling apk '$1'"
			adb shell pm disable-user --user 0 "$1"
			return 0
	}

	status "apk '$1' is already disabled"
}

# Enable Package
enableApp() {
	[ -n "$(adb shell pm list packages -e | grep "$1" || true)" ] || {
		status "Enabling apk '$1'"
			adb shell pm enable --user 0 "$1"
			return 0
	}

	status "Apk '$1' is alread enabled"
}

# Uninstall Package
uninstallApp() {
	[ -n "$(adb shell pm list packages -a | grep "$1" || true)" ] || {
		status "Uninstalling apk '$1'"
			adb shell pm uninstall --user 0 "$1"
			return 0
	}

	status "Apk '$1' is already uninstalled"
}

fdroidInstallApk() {
	apkIdentifier="$1" # e.g. com.oculus.twilight

	[ "$(adb shell pm list packages -a | grep "${apkIdentifier//_*/}" || true)" = "" ] || {
		status "The '$apkIdentifier' is already installed, skipping.."
		return 0
	}

	status "Downloading '$apkIdentifier' from F-droid"
	[ -e "$HOME/.cache/$projectName/$apkIdentifier.apk" ] || wget "https://f-droid.org/repo/$apkIdentifier.apk" -O "$HOME/.cache/$projectName/$apkIdentifier.apk"

	status "Installing '$apkIdentifier'"
	adb install "$HOME/.cache/$projectName/$apkIdentifier.apk"
}

# Install Apk from Path
installApkPath() {
	apkPath="$1"
	apkName="${apkPath//*\/}"
	if [ -n "$(adb shell pm list packages -a | grep "$apkName" || true)" ]; then
		status "Installing '$apkName' from '$apkPath'"
		adb install "$apkPath"
	else
		status "The app '$apkName' is already installed, skipping.."
	fi
}

installApkFromURL() {
	#* Installs Apk from provided URL
	#*
	#* Arguments:
	#*   1. Name of the apk e.g. com.veygax.eventhorizon
	#*   2. URL to download from (uses wget)
	#*   3. sha256sum of the downloaded file
	#*
	#* Example use in code:
	#*
	#*   installApkFromURL \
	#*     com.veygax.eventhorizon \
	#*     https://github.com/veygax/eventhorizon/releases/download/v1.2/eventhorizon.apk \
	#*     3c203087e3af677651fd78a00f42c5d4c7bd81e83292016a9b1427ca8e05d66a

	apkName="$1" # com.veygax.eventhorizon
	apkURL="$2" # https://github.com/veygax/eventhorizon/releases/download/v1.2/eventhorizon.apk
	sha256sum="$3" # 3c203087e3af677651fd78a00f42c5d4c7bd81e83292016a9b1427ca8e05d66a

	status "Evaluating installation request for apk '$apkName'"

	# shellcheck disable=SC2310 # False positive, report to upstream
	isApkNameInstalled "$apkName" || {
		status "Downloading '$apkName' from '$apkURL' to '$projectCacheDir/$apkName.apk'"
			[ -e "$projectCacheDir/$apkName.apk" ] || wget "$apkURL" -O "$projectCacheDir/$apkName.apk"

		status "Checking sha256sum of $apkName against $sha256sum"
			# Checksum
			echo "$sha256sum  $projectCacheDir/$apkName.apk" | sha256sum -c - || {
				rm "$projectCacheDir/$apkName.apk"
				die 1 "sha256sum '$sha256sum' for file '$projectCacheDir/$apkName.apk' does not match!"
			}

		status "Installing '$apkName' from '$projectCacheDir/$apkName.apk"
			adb install "$projectCacheDir/$apkName.apk"

		return 0
	}

	status "Apk '$apkName' is already installed, skipping.."
}

deviceRootCheck() {
	status "Checking device's root capability"

	! adb shell su -c "id -u" 2>/dev/null || {
		export rootable=0
		status "Confirmed device root"
		return 0
	}

	warn "Device is not rooted!"
	return 1
}

export commonsSourced=0

deviceRootCheck || true
