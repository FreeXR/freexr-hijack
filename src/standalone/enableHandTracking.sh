#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

###! Enables Hand Tracking
###!
###! ## Background
###! For META Quest devices using a de-metafied setup it's not possible to enable hand tracking via the User Interface as it's missing the `guidebook` app that showcases introduction and safety breafing with button to enable hand tracking.
###!
###! This can be bypassed via using (root required):
###!
###!     oculussetting --set hand_tracking_opt_in 1 hand_tracking_enabled 1
###!

set -e # Exit on false return

# shellcheck source=../lib/common.sh
. "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
enableHandTracking() {
	case "$productManufacturer" in
		"Oculus")
			status "Evaluating request to enable hand-tracking"

			! deviceRootCheck || {
				status "Root detected, enabling hand-tracking via oculussetting"
					adb shell su -c "oculussetting --set hand_tracking_opt_in 1 hand_tracking_enabled 1"
					return 0
			}

			warn "Device is not rooted! Installing guidebook apk, hand-tracking MUST be enabled in settings by the user to be enabled"
				installApkPath "$gitRoot/vendor/guidebook.apk" # Install guidebook (Needed to enable Hand-Tracking)
				return 0
		;;
		*) fixme "The Manufacturer '$productManufacturer' is not yet implemented"
	esac
}

enableHandTracking # Call The Function
