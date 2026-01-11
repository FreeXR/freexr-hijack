#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Script to disable automatic and forced updates

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
disableUpdates () {
	status "Checking status of update feature"

	case "$productManufacturer" in
		"Oculus")
			case "$productName" in
				"monterey") true ;;
				"holywood") true ;;
				"seacliff") true ;;
				"eureka") true ;;
				"panther") true ;;
				*) die 1 "This device '$productName' is not yet implemented"
			esac

			disableApp com.oculus.updater # Disable updates on META Quest Devices

			if deviceRootCheck; then
				case "$(adb shell su -c 'stat -c "%a" /data/data/com.oculus.updater')" in
					# Android quirks may remove the leading zeros
					"000"|"0") true ;; 
					*) adb shell su -c 'chmod -vR 000 /data/data/com.oculus.updater'
				esac

				adb shell test -d /data/data/ota || adb shell su -c 'mkdir -v /data/data/ota'
				case "$(adb shell su -c 'stat -c "%a" /data/data/ota')" in
					# Android quirks may remove the leading zeros
					"000"|"0") true ;; 
					*) adb shell su -c 'chmod -vR 000 /data/data/ota'
				esac

				adb shell test -d /data/data/ota_package || adb shell su -c 'mkdir -v /data/data/ota_package'
				case "$(adb shell su -c 'stat -c "%a" /data/data/ota_package')" in
					# Android quirks may remove the leading zeros
					"000"|"0") true ;; 
					*) adb shell su -c 'chmod -vR 000 /data/data/ota_package'
				esac
			else
				warn "Device is not rooted, unable to set chmod 000 on /data/data/{ota,ota_package,com.oculus.updater} for extra safety! Root your device and then re-run this script!"
			fi

			return 0
		;;
		*) fixme "Device '$productName' of Manufacturer '$productManufacturer' is not yet implemented"
	esac
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# disableUpdates "$@" # Run the Library if called as standalone Script
