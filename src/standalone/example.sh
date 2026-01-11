#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Example standalone script

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
sayHello() {
	printf "%s\n" "Hello, World!"
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# sayHello # Call The Function
