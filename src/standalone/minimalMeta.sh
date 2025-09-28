#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! To Enable META Store with ability to download and use apps

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
minimalMeta() {
	enableApp com.oculus.store # Enable META Store
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# minimalMeta # Call The Function
