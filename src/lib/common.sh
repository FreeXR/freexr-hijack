#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

set -e # Exit on False

# --- Helpers ---
die() { printf "FATAL: %s\n" "$2"; exit ;}
warn() { printf "WARN: %s\n" "$1" ;}
status() { printf "STATUS: %s\n" "$1" ;}

# --- Exports ---
projectName="FreeXR-Hijack"

# shellcheck disable=SC2034 # Optional Variable
gitRoot="$(git rev-parse --show-toplevel || true)"

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
# Disable Package
disableApp() {
	[ -n "$(adb shell pm list packages -d | grep "$1" || true)" ] || adb shell pm disable-user --user 0 "$1"
}

# Enable Package
enableApp() {
	[ -n "$(adb shell pm list packages -e | grep "$1" || true)" ] || adb shell pm enable --user 0 "$1"
}

# Uninstall Package
uninstallApp() {
	[ -n "$(adb shell pm list packages -a | grep "$1" || true)" ] || adb shell pm uninstall --user 0 "$1"
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
	apkURL="$1"
	apkName="${apkURL//*\/}"
	apkFileName="${2:-"$apkName"}"

	if [ "$(adb shell pm list packages -a | grep "${apkFileName//.apk}" || true)" = "" ]; then
		status "Downloading '$apkFileName' from '$apkURL' to '$HOME/.cache/$projectName/$apkFileName'"
		[ -e "$HOME/.cache/$projectName/$apkFileName" ] || wget "$apkURL" -O "$HOME/.cache/$projectName/$apkFileName"

		status "Installing '${apkFileName//.apk}'"
		adb install "$apkPath"
	else
		status "The app '${apkFileName//.apk}' is already installed, skipping.."
	fi
}
