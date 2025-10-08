#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

set -e # Exit on False

# --- Colors ---
## Reset to normal: \033[0m
NORM="\033[0m"

# BLACK="\033[0;30m"
# GRAY="\033[1;30m"
RED="\033[0;31m"
# LRED="\033[1;31m"
GREEN="\033[0;32m"
# LGREEN="\033[1;32m"
YELLOW="\033[0;33m"
# LYELLOW="\033[1;33m"
BLUE="\033[0;34m"
# LBLUE="\033[1;34m"
# PURPLE="\033[0;35m"
PINK="\033[1;35m"
CYAN="\033[0;36m"
# LCYAN="\033[1;36m"
# LGRAY="\033[0;37m"
# WHITE="\033[1;37m"

## Attributes:
# UNDERLINE="\033[4m"
# FIXME(Krey): No idea why is this not working
BOLD="\033[1m"
# INVERT="\033[7m"

# --- Helpers ---
die() { printf "$BOLD${RED}FATAL: $NORM%s\n" "$2"; exit ;}
warn() { printf "$BOLD${YELLOW}WARN: $NORM%s\n" "$1" ;}
status() { printf "$BOLD${BLUE}STATUS: $NORM%s\n" "$1" ;}
fixme() { printf "$BOLD${PINK}FIXME: $NORM%s\n" "$1"; exit ;}
debug() { [ -z "$DEBUG" ] || printf "$BOLD${CYAN}DEBUG: $NORM%s\n" "$1" ;}
success() { printf "$BOLD${GREEN}OK: $NORM%s\n" "$1"; return 0 ;}

[ -z "$DEBUG" ] || ( die 1 test )
[ -z "$DEBUG" ] || ( success test )
debug test
[ -z "$DEBUG" ] || status test
[ -z "$DEBUG" ] || warn test
[ -z "$DEBUG" ] || ( fixme test )

# --- Exports ---
projectName="FreeXR-Hijack"

# --- Command Check ---
status "Checking for required dependencies"
	command -v awk 1>/dev/null && awk --version | head -n1 | awk -v p="$(which awk || true) ::" '{print p, $0}'
	command -v git 1>/dev/null && git --version | awk -v p="$(which git || true) ::" '{print p, $0}'
	command -v adb 1>/dev/null && adb --version | awk -v p="$(which adb || true) ::" '{print p, $0}'

# shellcheck disable=SC2034 # Optional Variable
gitRoot="$(git rev-parse --show-toplevel || true)"

projectCacheDir="$HOME/.cache/$projectName"

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
	adb shell pm list packages -a "$1" | grep -o "package:$1" >/dev/null || { warn "Package '$1' is not installed on this system, unable to disable"; return 0 ;}

	# shellcheck disable=SC2312 # Dunno how else to manage this
	adb shell pm list packages -d | grep -o "package:$1" >/dev/null || {
		status "Disabling apk '$1'"
			adb shell pm disable-user --user 0 "$1"
			return 0
	}

	debug "Apk '$1' is already disabled"
}

# Enable Package
enableApp() {
	adb shell pm list packages -a "$1" | grep -o "package:$1" >/dev/null || { warn "Package '$1' is not installed on this system, unable to enable"; return 0 ;}

	# shellcheck disable=SC2312 # Dunno how else to manage this
	adb shell pm list packages -e | grep -o "package:$1" >/dev/null || {
		status "Enabling apk '$1'"
			adb shell pm enable --user 0 "$1"
			return 0
	}

	debug "Apk '$1' is alread enabled"
}

# Uninstall Package
uninstallApp() {
	adb shell pm list packages -a "$1" | grep -o "package:$1" >/dev/null || { debug "Package '$1' is already not installed on this system"; return 0 ;}

	# shellcheck disable=SC2312 # Dunno how else to manage this
	! adb shell pm list packages -a | grep -o "package:$1" >/dev/null || {
		status "Uninstalling apk '$1'"
			adb shell pm clear "$1"
			adb shell pm uninstall --user 0 "$1"
			return 0
	}

	debug "Apk '$1' is already uninstalled"
}

fdroidInstallApk() {
	apkIdentifier="$1" # e.g. com.oculus.twilight

	[ "$(adb shell pm list packages -a | grep "${apkIdentifier//_*/}" || true)" = "" ] || {
		debug "The '$apkIdentifier' is already installed, skipping.."
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
		debug "The app '$apkName' is already installed, skipping.."
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

	debug "Evaluating installation request for apk '$apkName'"

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

	debug "Apk '$apkName' is already installed, skipping.."
}

deviceRootCheck() {
	checkCmd="$(adb shell su -c "true" >/dev/null 2>&1; echo "$?")"

	case "$checkCmd" in
		0)
			debug "Device is confirmed rooted"
			return 0 ;;
		127) 
			debug "Device is not rooted"
			return 1 ;;
		*) die 127 "Root checking command returned unimplemented return: $checkCmd"
	esac
}

export commonsSourced=0
