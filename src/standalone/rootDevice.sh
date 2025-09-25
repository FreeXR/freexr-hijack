#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Installs Event Horizon app which is implementing root methods for various devices with option to root on boot

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
rootDevice() {
	status "Attempting to root the device"

	[ "$rootable" != 0 ] || {
		success "Device is already rooted, skipping setup"
		return 0
	}

	case "$productManufacturer" in
		"Oculus")
			case "$productName" in
				"eureka"|"panther")
					installApkFromURL \
						com.veygax.eventhorizon \
						https://github.com/veygax/eventhorizon/releases/download/v2.3.0/eventhorizon.apk \
						b12f66f5ac3dc3162832f503e0154f1492eff971b4d232e2a19d85b0588b613e

					# Root the headset
						status "Rooting the device"
							adb shell am start -S -n com.veygax.eventhorizon/.ui.activities.MainActivity --ez auto_root true

							# # Wait for EH to finish rooting the device..
							# 	while [ "$(adb shell echo 0)" = 0 ]; do
							# 		debug "Waiting for EventHorizon to finish rooting.."
							# 		# FIXME(Krey): We are assuming that in 10 seconds it's gonna be finished which is BAD implementation
							# 		sleep 10
							# 	done

							# # Wait for the device to come back up with root
							# 	status "Waiting for the device to come back up"
							# 	while [ "$(adb shell echo 0)" != 0 ]; do
							# 		debug "Waiting for the device to come back up"
							# 		sleep 1
							# 	done

							# # Check root
							# 	status "Checking root"
							# 	deviceRootCheck || die 1 "Rooting failed!"
							# 	[ "$rootable" != 0 ] || success "Device was successfully rooted"

							die 1 "Please perform the root in the headset and then re-run the script, this is not yet automated FIXME"
				;;
				*) die 1 "This device '$productName' is not yet implemented in '$0'"
			esac
	esac
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# rootDevice # Call The Function
