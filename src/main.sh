#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

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
. "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# shellcheck source=./standalone/adbPulseCheck.sh
. "$gitRoot/src/standalone/adbPulseCheck.sh"

# shellcheck source=./standalone/disableUpdates.sh
. "$gitRoot/src/standalone/disableUpdates.sh"

# shellcheck source=./standalone/enableHandTracking.sh
. "$gitRoot/src/standalone/enableHandTracking.sh"

# shellcheck source=./standalone/removeStockApps.sh
. "$gitRoot/src/standalone/removeStockApps.sh"

# shellcheck source=./standalone/hijack.sh
. "$gitRoot/src/standalone/hijack.sh"

# shellcheck source=./standalone/identifyDevice.sh
. "$gitRoot/src/standalone/identifyDevice.sh"

# shellcheck source=./standalone/rootDevice.sh
. "$gitRoot/src/standalone/rootDevice.sh"

#! Command wrapper to run this on the headsets as standalone or on a host system as wired
w_call() {
	Wired -> adb shell cmd
	standalone -> cmd
	wired-multi -> adb -s .. shell cmd
	standalone-multi -> cmd

	if multiple adb devices; then
		require selectedDevice to be set

	if standalone; then
		set standalone flag?

	By default: Assume no adb



	case "$wrapper" in
		"wired"|"")
			if [ -n "$selectedDevice" ]; then
				adb -s "$selectedDevice" "$@"
			else
				adb "$@"
			fi
		;;
		"standalone") exec "$@" ;;
		*) die 1 "The variable 'wrapper' stores unimplemented value '$wrapper' in w_cmd() function"
	esac
}

# Process Arguments
while [ "$#" -gt 0 ]; do case "$1" in
	"--select")
		case "$2" in
			*.*.*.*:*) # Matching by IP for WireLESS ADB
				true
			;;
			[A-Z0-9]+) # By Seirla Number for wired ADB
				true
			;;
			*) die 1 "The value for 'select' argument does not pass sanity: $2"
		esac

		selectedDevice="$2"

		shift
	;;
	"--mode")
		case "$2" in
			"wired") true ;;
			"standalone") true ;;
			*) die 1 "Interface mode not implemented: $2"
		esac

		export wrapper="$2"
	;;
	"-d"|"--debug") export DEBUG=1 ;;
	"--HIJACK")
		adbPulseCheck

		identifyDevice

		disableUpdates

		deviceRootCheck

		rootDevice

		enableHandTracking

		removeStockApps

		hijack

		adb reboot

		success "Hijack Completed!"
	;;
	"--debloat")
		adbPulseCheck

		identifyDevice

		removeStockApps
	;;
	"--enable-prox")
		fixme "Argument '$1' is not implemented"
	;;
	"--disable-prox")
		identifyDevice

		status "Attempting to disable proximity sensor on the device"

		case "$productName" in
			eureka) adb shell am broadcast -a com.oculus.vrpowermanager.prox_close ;;
			*) die 1 "Device '$productName' is not implemented for disabling proximity sensor"
		esac
	;;
	"--poweroff")
		adb shell reboot -p
	;;
	*) die 3 "Argument not implemented: $1"
esac; shift; done
