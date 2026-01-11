#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Script to remove all vendor-supplied apps to debloat the device while maintaining minimal functionality

set -e # Exit on False

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Attempts to remove all META applications, if we can't remove them then we disable
removeStockApps() {
	debug "Attempting to debloat the device"

	case "$productManufacturer" in
		"Oculus")
			case "$productName" in
				"eureka"|"panther") true ;;
				*) die 1 "This device '$productName' is not yet implemented in '$0'"
			esac

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

			# --- VR Camera Service ---
			enableApp com.oculus.metacam # Required for camera access in VR environments (disabled otherwise)


			# --- System Utilities and Miscellaneous ---
			disableApp com.oculus.systemutilities # System utilities (opens files, unnecessary for minimal setup)
			enableApp com.oculus.panelapp.library # Oculus library (might not be needed for minimal UI)

			# --- Disable Meta and Oculus Bloatware ---
			disableApp com.oculus.avatareditor # Avatar editor (doesn’t load without Meta services, unnecessary)
			disableApp com.oculus.identitymanagement.service # Identity management (bloat, not necessary)
			disableApp com.oculus.firsttimenux # First-time setup (you’re skipping this for a minimal setup)
				disableApp com.oculus.nux.ota
			disableApp com.oculus.hzosgallery # VR gallery (not needed)
			# FIXME(Krey): Protected Package
				# disableApp com.oculus.q4b.mdm # Device management (disabled)
			disableApp com.oculus.store # Oculus store (not needed for now)
			disableApp com.oculus.assistant # Voice assistant (disabled)
			disableApp com.oculus.socialplatform # Social services (disabled)
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
			[ "$productName" != "eureka" ] || enableApp com.android.adservices.api # Ad services (disabled)
			enableApp com.android.hotspot2.osulogin # Hotspot login
			enableApp com.android.externalstorage # External storage
			enableApp com.android.keychain # Keychain
			enableApp com.android.permissioncontroller # Permission controller

			# --- Services Related to Meta Apps (To Be Disabled) ---
			[ "$productName" != "eureka" ] || disableApp com.oculus.horizonmediaplayer # Horizon media player (not needed)
			disableApp com.oculus.presence # Presence (disabled for minimal UI)

			# --- Other Non-Essential System Services ---
			disableApp com.oculus.systemactivities # System activities tracking (disabled)
			disableApp com.oculus.quickpromotionservice # Not required
			[ "$productName" != "eureka" ] || disableApp com.oculus.externaldisplayservice # External display service (not needed)
			disableApp com.oculus.magicislandcastingservice # VR casting (not needed)
			disableApp com.oculus.os.clearactivity # No clear activity required
			disableApp com.oculus.panelapp.kiosk # Kiosk mode (disabled)
			disableApp com.oculus.deviceauthserver # Device authentication (disabled)

			# --- Additional Cleanup ---
			disableApp com.oculus.linefrequencyservice # Line frequency (unnecessary)
			disableApp com.oculus.tv # TV app (unnecessary)
			uninstallApp com.facebook.orca # Messenger App
			uninstallApp com.oculus.facebook # Facebook App
			uninstallApp com.oculus.igvr # Instagram App
			uninstallApp com.meta.curio.toybox # First Encounters
			uninstallApp com.meta.curio.ruler # Layour App
			uninstallApp com.facebook.arvr.quillplayer # Theater Elsewhere
			enableApp com.android.documentsui # Files App
			uninstallApp com.whatsapp # Whatsapp App
			disableApp com.oculus.fitnesstracker # Oculus Move
			# disableApp com.oculus.helpcenter
			disableApp com.oculus.browser
			disableApp com.oculus.magicislandcastingservice # "Casting" app
			disableApp com.oculus.os.chargecontrol # Charge Control
			disableApp com.oculus.extrapermissions # Extra Permissions
			# enableApp com.android.federatedcompute.services # Federated Computing Service
			disableApp com.meta.federatedcomputing.oculus # Federated Computing Service
			disableApp com.oculus.guidebook # Guide Book (Needed To Enable Hand Tracking)
			# disableApp com.meta.handseducationmodule # handseducationmodule
			disableApp com.oculus.explore # Horizon Feed
			disableApp com.facebook.horizon # Horizon Worlds
			disableApp com.oculus.xrstreamingclient # Link
			disableApp com.oculus.mrds # Meta Remote enableApp com.android Streaming Service
			enableApp com.oculus.panelapp.settings # Configuration in panelapp, breaks WiFi if disabled
			disableApp com.oculus.assistant # Oculus Assistant Service
			disableApp com.oculus.systemutilities # Oculus System Utilities
			disableApp com.oculus.os.qrcodereader # QR Code Reader
			disableApp com.meta.rl.trust.service # RL Trust Service
			disableApp com.oculus.panelapp.kiosk # Shared Mode
			disableApp com.oculus.systemresource # System Resource
			disableApp com.oculus.vrcast # VR casting service
			disableApp com.oculus.vrprivacycheckup # VrPrivacyCheckup

			# --- Telemetry ---
				disableApp com.oculus.notification_proxy # Notification proxy
				disableApp com.oculus.ovrmonitormetricsservice # Oculus telemetry/metrics collection
				disableApp com.oculus.bugreportuploader # Bug report uploader
				# FIXME(Krey): Protected Package
					# enableApp com.oculus.appsafety # App safety service

			# --- Not Preset In Android Settings App View ---
				# FIXME(Krey): There is a lot of things that can be disable and should be disabled
				enableApp com.android.modulemetadata # Android system metadata
				enableApp com.android.connectivity.resources # Network connectivity services
				enableApp com.oculus.vrbluetooth # VR Bluetooth management
				enableApp com.meta.horizonadidservice # Ad ID service for Horizon
				enableApp com.meta.AccountsCenter.pwa # Meta account management PWA
				enableApp com.oculus.permissioncontroller.rro # Runtime permissions handler
				enableApp com.oculus.horizon # Main Horizon VR social app
				enableApp com.oculus.configuration # Oculus system configuration
				enableApp com.android.providers.contacts # Contacts provider
				enableApp com.android.companiondevicemanager # Companion device manager
				enableApp com.android.cts.priv.ctsshim # CTS (test) shim
				enableApp com.android.providers.downloads # Download manager
				enableApp com.meta.systemui # System UI modifications
				enableApp horizonos.platform # Horizon OS platform service
				enableApp com.android.networkstack # Android network services
				enableApp android.ext.shared # Shared Android extensions
				enableApp com.android.networkstack.tethering # Tethering/network services
				enableApp com.oculus.guardian # Guardian boundary system
				enableApp com.android.keychain # Keychain (credentials) service
				enableApp com.android.webview # WebView component
				enableApp com.android.virtualmachine.res # VM resource service
				enableApp com.android.shell # Android shell
				enableApp com.oculus.bugreportservice # Bug reporting service
				enableApp com.android.inputdevices # Input devices management
				enableApp com.android.nearby.halfsheet # Nearby sharing UI
				enableApp com.android.bookmarkprovider # Bookmark provider
				enableApp com.oculus.userserver2 # User management server
				enableApp com.android.sharedstoragebackup # Shared storage backup
				enableApp com.oculus.settings.rro # Settings overlay
				enableApp com.oculus.micservice # Microphone service
				enableApp com.android.providers.media # Media storage provider
				enableApp com.android.providers.calendar # Calendar provider
				enableApp com.android.providers.blockednumber # Blocked numbers provider
				enableApp com.android.statementservice # Android safety statements
				enableApp com.meta.automation.pauldron.vr # Automation/VR service
				enableApp com.oculus.backuptransportservice # Backup transport
				enableApp com.oculus.oemconfig # OEM configuration
				enableApp com.oculus.mrservice # Mixed reality service
				enableApp com.android.proxyhandler # Proxy settings
				enableApp com.android.safetycenter.resources # Safety Center resources
				enableApp com.android.managedprovisioning # Device provisioning
				enableApp com.android.healthconnect.controller # HealthConnect service
				enableApp com.android.backupconfirm # Backup confirmation service
				enableApp com.android.mtp # Media Transfer Protocol
				# enableApp com.oculus.accountscenter # Oculus account center
				enableApp com.oculus.maintenanceboot # Maintenance/boot service
				enableApp com.android.appsearch.apk # AppSearch system service
				enableApp com.oculus.cvp # CVP (VR runtime component)
				enableApp com.oculus.websafety # Web safety service
				enableApp com.oculus.labservice # Lab service for testing
				enableApp com.android.ext.adservices.api # Android Ad Services API
				enableApp com.oculus.os.voidactivity # Void activity (internal)
				enableApp com.qualcomm.timeservice # Qualcomm time sync service
				enableApp com.oculus.externalstorage # External storage management
				enableApp com.qualcomm.wfd.service # Wi-Fi display service
				enableApp com.oculus.integrity # System integrity service
				enableApp com.oculus.ocms # Oculus content management
				enableApp com.android.localtransport # Local transport service
				enableApp android # Core Android package
				enableApp com.android.rkpdapp # Unknown system app
				enableApp com.android.permissioncontroller # Android permission controller
				enableApp com.oculus.metacam # Metacam service
				enableApp com.meta.frameworkpackagestubs # Framework stubs
				enableApp com.android.pacprocessor # PAC processor for networks
				enableApp com.oculus.captionservice # Captioning service
				enableApp com.oculus.vralertservice # VR alert service
				enableApp com.android.providers.media.module # Media module provider
				enableApp horizon.platform.service # Horizon platform service
				# enableApp com.oculus.helpcenter # Help Center
				enableApp com.android.settings # Android settings
				enableApp com.oculus.guardianresources # Guardian resources
				enableApp com.oculus.os.vrusb # VR USB service
				enableApp com.android.federatedcompute.services # Federated compute
					# Apparently needed to get UI to work
					enableApp com.oculus.systemdriver # System driver
				enableApp com.oculus.statscollector # Stats collector
				# FIXME(Krey): Protected Package
					# enableApp com.android.devicelockcontroller # Device lock
				enableApp com.android.documentsui # Document picker
				enableApp com.android.adservices.api # Android ad services
				enableApp com.android.providers.tv # TV provider
				enableApp com.android.health.connect.backuprestore # Health Connect backup/restore
				enableApp com.meta.android.rro # Meta overlay RRO
				enableApp com.oculus.os.cm # Oculus CM service
				enableApp com.facebook.wearable.system.location.proxy # Location proxy
				enableApp com.android.intentresolver # Intent resolver
				enableApp com.android.certinstaller # Certificate installer
				enableApp com.oculus.os.vrlockscreen # VR lockscreen
				enableApp android.ext.services # Android extension services
				enableApp com.oculus.preloader # Preloader
				enableApp com.android.wifi.resources # Wi-Fi resources
				enableApp com.android.wifi.dialog # Wi-Fi dialog
				enableApp com.android.captiveportallogin # Captive portal login
				enableApp com.android.sdksandbox # SDK sandbox
				enableApp com.meta.transport # Transport service
				enableApp com.oculus.vrosconfigwriterdeprecated # VR OS config writer
				enableApp com.android.providers.settings # Settings provider
				enableApp com.oculus.preshutdowntaskservice # Pre-shutdown tasks
				enableApp oculus.platform # Oculus platform
				enableApp com.facebook.spatial_persistence_service # Spatial persistence service
				enableApp com.android.location.fused # Fused location provider
				enableApp com.android.vpndialogs # VPN dialog
				enableApp com.android.uwb.resources # UWB (Ultra-wideband) resources
				enableApp com.oculus.bodyapiservice # Body tracking APIs
				# enableApp com.meta.handseducationmodule # Hand tracking education
				enableApp com.android.ondevicepersonalization.services # On-device personalization
				enableApp com.android.htmlviewer # HTML viewer
				enableApp horizon.platform.service.notification # Horizon notification service
				enableApp com.oculus.systemux # System UX
				enableApp com.facebook.wearable.system.location.service # Wearable location service
				enableApp com.android.providers.userdictionary # User dictionary
				enableApp com.android.cts.ctsshim # CTS test shim
				enableApp com.android.bluetooth # Bluetooth service
				enableApp com.android.storagemanager # Storage manager
				enableApp com.android.packageinstaller # Package installer
				enableApp com.android.soundpicker # Sound picker
				enableApp com.android.provision # Device provisioning
				enableApp com.android.hotspot2.osulogin # Hotspot 2.0 login
				enableApp com.android.externalstorage # External storage
				enableApp com.oculus.appautomation # App automation
				enableApp com.android.server.telecom # Telecom server

			# --- Link ---
			disableApp com.meta.pclinkservice.server

			# --- UI ---
			enableApp com.oculus.vrshell # Default User Environment
			enableApp com.oculus.shellenv # Core VR shell environment
			# FIXME(Krey): Might not be needed
				enableApp com.oculus.vrshell.desktop # VR shell desktop support

			# --- Remote Desktop ---
			# disableApp com.oculus.remotedesktop

			# --- Companion Server ---
			# FIXME(Krey): Sanitize Companion Server so that META can't use it as backdoor, likely by decompiling it and replacing it with adjusted app
			# disable com.oculus.companion.server # Companion server (protected package, cannot be disabled without root)
		;;
		*) fixme "This Manufacturer '$productManufacturer' is not yet implemented!"
	esac
}

# FIXME(Krey): Figure out how to prevent this from being executed on `. path/to/this/file`
# removeStockApps
