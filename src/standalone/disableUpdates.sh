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

			return 0
		;;
		*) fixme "Device '$productName' of Manufacturer '$productManufacturer' is not yet implemented"
	esac
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# disableUpdates "$@" # Run the Library if called as standalone Script
