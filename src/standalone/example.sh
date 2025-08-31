#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

###! Example standalone script

set -e # Exit on false return

# shellcheck source=../lib/common.sh
. "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
sayHello() {
	printf "%s\n" "Hello, World!"
}

sayHello # Call The Function
