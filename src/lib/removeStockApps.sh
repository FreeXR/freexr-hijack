#!/usr/bin/env sh
# shellcheck shell=sh # POSIX

set -e # Exit on False

# shellcheck source=./common.sh
# FIXME-QA(Krey): This is not meant to be here, but sourcing above doesn't work?
# shellcheck disable=SC2154 # Referenced but not assigned, but for library?

# Attempts to remove all META applications, if we can't remove them then we disable
removeStockApps() {
	case "$productManufacturer" in
		"Oculus")
			case "$productName" in
				"eureka") true ;;
				*) die 1 "This device '$productName' is not yet implemented"
			esac

			# --- Prevent OTA Updates ---
			disableApp com.oculus.updater # Disable updates on META Quest Devices

			# --- Essential Services for VR Shell (Keep enableAppd) ---
			enableApp com.oculus.vrshell # VR Shell itself, essential for VR environment
			enableApp com.oculus.os.vrlockscreen # VR lock screen functionality (important for secure navigation in VR)

			# --- Core System Services ---
			enableApp com.android.settings # Basic settings for configuration
			enableApp com.android.networkstack # Core networking stack (important for Wi-Fi, networking)
			enableApp com.android.inputdevices # Input devices (touch, controllers)
			enableApp com.android.keychain # Keychain for secure data management
			enableApp com.android.providers.settings # Stores settings preferences (critical for system setup)
			enableApp com.oculus.panelapp.settings # Quick Settings from bar

			# --- Core Oculus Services (Minimal Set) ---
			# enableApp com.oculus.q4bservice # Manages Oculus for Business services (optional based on use case) PROTECTED
			# enableApp com.oculus.vrusb # Manages USB connectivity (important for VR accessories) PROTECTED
			enableApp com.oculus.systemresource # Displays technical system data (useful but not intrusive)

			# --- VR Camera Service ---
			enableApp com.oculus.metacam # Required for camera access in VR environments (disabled otherwise)

			# --- System Utilities and Miscellaneous ---
			disableApp com.oculus.systemutilities # System utilities (opens files, unnecessary for minimal setup)
			disableApp com.oculus.panelapp.library # Oculus library (not needed for minimal UI)

			# --- Disable Meta and Oculus Bloatware ---
			disableApp com.oculus.avatareditor # Avatar editor (doesn’t load without Meta services, unnecessary)
			disableApp com.oculus.identitymanagement.service # Identity management (bloat, not necessary)
			disableApp com.oculus.firsttimenux # First-time setup (you’re skipping this for a minimal setup)
			disableApp com.meta.pclinkservice.server # Oculus Link (disabled as you are using a 3rd party replacement)
			disableApp com.oculus.hzosgallery # VR gallery (not needed)
			disableApp com.oculus.q4b.mdm # Device management (disabled)
			disableApp com.oculus.store # Oculus store (not needed for now)
			disableApp com.oculus.assistant # Voice assistant (disabled)
			disableApp com.oculus.socialplatform # Social services (disabled)
			disableApp com.oculus.explore # Explore app (not required)
			disableApp com.oculus.mrds # Mixed reality (not needed)
			disableApp com.oculus.os.qrcodereader # QR Code reader (fixed package name)

			# --- Android Files (Not Required with 3rd Party System) ---
			enableApp com.android.providers.contacts # Contact management (not needed)
			enableApp com.android.providers.media.module # Media module (disabled)
			enableApp com.android.providers.downloads # Download manager
			enableApp com.android.providers.calendar # Calendar (not needed)
			enableApp com.android.shell # Shell (disabled)
			enableApp com.android.externalstorage # External storage (not needed)
			enableApp com.android.captiveportallogin # Captive portal login (not needed)

			# --- Miscellaneous Android System Services ---
			enableApp com.android.wifi.resources # Wi-Fi resources (handled by networkstack)
			disableApp com.android.adservices.api # Ad services (disabled)
			enableApp com.android.hotspot2.osulogin # Hotspot login
			enableApp com.android.externalstorage # External storage
			enableApp com.android.keychain # Keychain
			enableApp com.android.permissioncontroller # Permission controller

			# --- Services Related to Meta Apps (To Be Disabled) ---
			disableApp com.oculus.horizonmediaplayer # Horizon media player (not needed)
			disableApp com.oculus.presence # Presence (disabled for minimal UI)

			# --- Other Non-Essential System Services ---
			disableApp com.oculus.systemactivities # System activities tracking (disabled)
			disableApp com.oculus.quickpromotionservice # Not required
			disableApp com.oculus.externaldisplayservice # External display service (not needed)
			disableApp com.oculus.magicislandcastingservice # VR casting (not needed)
			disableApp com.oculus.os.clearactivity # No clear activity required
			disableApp com.oculus.panelapp.kiosk # Kiosk mode (disabled)
			disableApp com.oculus.deviceauthserver # Device authentication (disabled)

			# --- Additional Cleanup ---
			disableApp com.oculus.linefrequencyservice # Line frequency (unnecessary)
			disableApp com.oculus.tv # TV app (unnecessary)

			# --- Companion Server ---
			# FIXME(Krey): Sanitize Companion Server so that META can't use it as backdoor, likely by decompiling it and replacing it with adjusted app
			# disable com.oculus.companion.server # Companion server (protected package, cannot be disabled without root)
		;;
		*) die 1 "This Manufacturer '$productManufacturer' is not yet implemented!"
	esac
}
