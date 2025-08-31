#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

###! Installs Event Horizon app which is implementing root methods for various devices with option to root on boot

set -e # Exit on false return

# shellcheck source=../lib/common.sh
. "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
rootOnBoot() {
	installApkFromURL \
		com.veygax.eventhorizon \
		https://github.com/veygax/eventhorizon/releases/download/v1.2/eventhorizon.apk \
		3c203087e3af677651fd78a00f42c5d4c7bd81e83292016a9b1427ca8e05d66a
}

rootOnBoot # Call The Function
