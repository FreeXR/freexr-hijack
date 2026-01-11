#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! ADB Pulse Check

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
adbPulseCheck() {
	adb shell return 0 || die 1 "Device is not connected and authentificated with adb server"
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# adbPulseCheck # Call The Function
