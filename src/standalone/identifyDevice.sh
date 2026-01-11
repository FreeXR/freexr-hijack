#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Script to Identify Device on ADB

set -e # Exit on false return

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Core
identifyDevice() {
	# shellcheck disable=SC2155 # Optional Variable
	export productModel="$(adb shell getprop ro.product.model)"
		status "Product Model Detected: $productModel"

	# shellcheck disable=SC2155 # Optional Variable
	export productManufacturer="$(adb shell getprop ro.product.manufacturer)"
		status "Product Manufacturer Detected: $productManufacturer"

	# shellcheck disable=SC2155 # Optional Variable
	export productName="$(adb shell getprop ro.product.name)"
		status "Product Name Detected: $productName"

	# shellcheck disable=SC2155 # Optional Variable
	export productDevice="$(adb shell getprop ro.product.device)"
		status "Product Device Detected: $productDevice"
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# identifyDevice # Call The Function
