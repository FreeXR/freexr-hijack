#!/usr/bin/env ksh
# shellcheck shell=ksh # POSIX

###! Script to remove all vendor-supplied apps to debloat the device while maintaining minimal functionality

set -e # Exit on False

# shellcheck source=../lib/common.sh
[ -n "$commonsSourced" ] || . "${gitRoot:-"$(git rev-parse --show-toplevel || true)"}/src/lib/common.sh" # Source Common Libraries

# Attempts to remove all META applications, if we can't remove them then we disable
removeStockApps() {
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

			# --- Core Oculus Services (Minimal Set) ---
			enableApp com.oculus.systemresource # Displays technical system data (useful but not intrusive)

			# --- VR Camera Service ---
			enableApp com.oculus.metacam # Required for camera access in VR environments (disabled otherwise)

			# --- System Utilities and Miscellaneous ---
			disableApp com.oculus.systemutilities # System utilities (opens files, unnecessary for minimal setup)
			enableApp com.oculus.panelapp.library # Oculus library (might not be needed for minimal UI)

			# --- Disable Meta and Oculus Bloatware ---
			disableApp com.oculus.avatareditor # Avatar editor (doesn’t load without Meta services, unnecessary)
			disableApp com.oculus.identitymanagement.service # Identity management (bloat, not necessary)
			disableApp com.oculus.firsttimenux # First-time setup (you’re skipping this for a minimal setup)
			disableApp com.meta.pclinkservice.server # Oculus Link (disabled as you are using a 3rd party replacement)
			disableApp com.oculus.hzosgallery # VR gallery (not needed)
			# FIXME(Krey): Protected Package
				# disableApp com.oculus.q4b.mdm # Device management (disabled)
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
			disableApp com.oculus.avatareditor # Avatar Editor
			disableApp com.oculus.magicislandcastingservice # "Casting" app
			disableApp com.oculus.vrcast # ???
			disableApp com.oculus.os.chargecontrol # Charge Control
			disableApp com.oculus.extrapermissions # Extra Permissions
			# enableApp com.android.federatedcompute.services # Federated Computing Service
			disableApp com.meta.federatedcomputing.oculus # Federated Computing Service
			disableApp com.oculus.guidebook # Guide Book (Needed To Enable Hand Tracking)
			disableApp com.oculus.firsttimenux # First Time Nux
				disableApp com.oculus.nux.ota
			disableApp com.oculus.hzosgallery # Gallery
			# disableApp com.meta.handseducationmodule # handseducationmodule
			disableApp com.oculus.explore # Horizon Feed
			disableApp com.oculus.socialplatform # ???
			disableApp com.facebook.horizon # Horizon Worlds
			disableApp com.oculus.vrcast
			disableApp com.oculus.xrstreamingclient # Link
			disableApp com.oculus.horizonmediaplayer # Media Player
			disableApp com.oculus.mrds # Meta Remote enableApp com.android Streaming Service
			enableApp com.oculus.panelapp.settings # Configuration in panelapp, breaks WiFi if disabled
			disableApp com.oculus.assistant # Oculus Assistant Service
			disableApp com.oculus.systemutilities # Oculus System Utilities
			disableApp com.oculus.os.qrcodereader # QR Code Reader
			disableApp com.meta.rl.trust.service # RL Trust Service
			disableApp com.oculus.panelapp.kiosk # Shared Mode
			disableApp com.oculus.systemresource # System Resource
			disableApp com.oculus.tv # TV
			disableApp com.oculus.metacam # VR Metacam Quest
			# disableApp com.oculus.vrprivacycheckup # VrPrivacyCheckup

			# --- Not Preset In Android Settings App View ---
			disableApp com.oculus.ovrmonitormetricsservice # Oculus telemetry/metrics collection
			enableApp com.android.modulemetadata # Android system metadata
			enableApp com.android.connectivity.resources # Network connectivity services
			disableApp com.oculus.vrbluetooth # VR Bluetooth management
			disableApp com.meta.horizonadidservice # Ad ID service for Horizon
			disableApp com.meta.AccountsCenter.pwa # Meta account management PWA
			enableApp com.oculus.permissioncontroller.rro # Runtime permissions handler
			disableApp com.oculus.horizon # Main Horizon VR social app
			disableApp com.oculus.configuration # Oculus system configuration
			disableApp com.oculus.bugreportuploader # Bug report uploader
			enableApp com.android.providers.contacts # Contacts provider
			disableApp com.oculus.hzosgallery # VR gallery app
			enableApp com.android.companiondevicemanager # Companion device manager
			enableApp com.android.cts.priv.ctsshim # CTS (test) shim
			enableApp com.android.providers.downloads # Download manager
			disableApp com.meta.systemui # System UI modifications
			disableApp horizonos.platform # Horizon OS platform service
			enableApp com.android.networkstack # Android network services
			enableApp android.ext.shared # Shared Android extensions
			disableApp com.oculus.identitymanagement.service # User identity service
			enableApp com.android.networkstack.tethering # Tethering/network services
			disableApp com.oculus.guardian # Guardian boundary system
			enableApp com.android.keychain # Keychain (credentials) service
			disableApp com.meta.pclinkservice.server # PC Link server
			enableApp com.android.webview # WebView component
			enableApp com.android.virtualmachine.res # VM resource service
			enableApp com.android.shell # Android shell
			disableApp com.oculus.bugreportservice # Bug reporting service
			enableApp com.android.inputdevices # Input devices management
			enableApp com.android.nearby.halfsheet # Nearby sharing UI
			disableApp com.oculus.systemactivities # System-level activities
			enableApp com.android.bookmarkprovider # Bookmark provider
			disableApp com.oculus.userserver2 # User management server
			disableApp com.facebook.horizon # Horizon social platform
			enableApp com.android.sharedstoragebackup # Shared storage backup
			disableApp com.oculus.settings.rro # Settings overlay
			disableApp com.oculus.micservice # Microphone service
			enableApp com.android.providers.media # Media storage provider
			enableApp com.android.providers.calendar # Calendar provider
			enableApp com.android.providers.blockednumber # Blocked numbers provider
			enableApp com.android.statementservice # Android safety statements
			enableApp com.meta.automation.pauldron.vr # Automation/VR service
			disableApp com.oculus.backuptransportservice # Backup transport
			disableApp com.oculus.oemconfig # OEM configuration
			disableApp com.oculus.mrservice # Mixed reality service
			enableApp com.android.proxyhandler # Proxy settings
			enableApp com.android.safetycenter.resources # Safety Center resources
			enableApp com.android.managedprovisioning # Device provisioning
			enableApp com.android.healthconnect.controller # HealthConnect service
			disableApp com.oculus.horizonmediaplayer # VR media player
			enableApp com.android.backupconfirm # Backup confirmation service
			enableApp com.android.mtp # Media Transfer Protocol
			# disableApp com.oculus.accountscenter # Oculus account center
			disableApp com.oculus.maintenanceboot # Maintenance/boot service
			enableApp com.android.appsearch.apk # AppSearch system service
			disableApp com.oculus.guidebook # VR guidebook
			disableApp com.oculus.explore # Explore VR app
			disableApp com.meta.federatedcomputing.oculus # Federated computing service
			enableApp com.oculus.cvp # CVP (VR runtime component)
			disableApp com.oculus.websafety # Web safety service
			disableApp com.oculus.vrcast # VR casting service
			disableApp com.oculus.labservice # Lab service for testing
			enableApp com.android.ext.adservices.api # Android Ad Services API
			disableApp com.oculus.externaldisplayservice # External display management
			disableApp com.oculus.os.voidactivity # Void activity (internal)
			enableApp com.qualcomm.timeservice # Qualcomm time sync service
			disableApp com.oculus.deviceauthserver # Device auth server
			disableApp com.oculus.tv # Oculus TV
			disableApp com.oculus.externalstorage # External storage management
			disableApp com.qualcomm.wfd.service # Wi-Fi display service
			disableApp com.oculus.integrity # System integrity service
			disableApp com.oculus.nux.ota # NUX (first-time setup) OTA
			disableApp com.oculus.ocms # Oculus content management
			enableApp com.android.localtransport # Local transport service
			enableApp android # Core Android package
			disableApp com.oculus.os.clearactivity # Clear activity service
			enableApp com.android.rkpdapp # Unknown system app
			enableApp com.android.permissioncontroller # Android permission controller
			disableApp com.oculus.metacam # Metacam service
			disableApp com.meta.frameworkpackagestubs # Framework stubs
			enableApp com.android.pacprocessor # PAC processor for networks
			disableApp com.oculus.captionservice # Captioning service
			disableApp com.oculus.vralertservice # VR alert service
			enableApp com.android.providers.media.module # Media module provider
			disableApp horizon.platform.service # Horizon platform service
			# FIXME(Krey): Protected Package
				# disableApp com.oculus.appsafety # App safety service
			# disableApp com.oculus.helpcenter # Help Center
			enableApp com.android.settings # Android settings
			disableApp com.oculus.guardianresources # Guardian resources
			disableApp com.oculus.os.vrusb # VR USB service
			enableApp com.android.federatedcompute.services # Federated compute
			disableApp com.oculus.systemdriver # System driver
			disableApp com.oculus.extrapermissions # Extra permissions handler
			disableApp com.oculus.statscollector # Stats collector
			# FIXME(Krey): Protected Package
				# enableApp com.android.devicelockcontroller # Device lock
			enableApp com.android.documentsui # Document picker
			enableApp com.android.adservices.api # Android ad services
			enableApp com.android.providers.tv # TV provider
			enableApp com.android.health.connect.backuprestore # Health Connect backup/restore
			disableApp com.oculus.fitnesstracker # Fitness tracking
			disableApp com.meta.android.rro # Meta overlay RRO
			disableApp com.oculus.os.cm # Oculus CM service
			disableApp com.facebook.wearable.system.location.proxy # Location proxy
			enableApp com.android.intentresolver # Intent resolver
			disableApp com.meta.rl.trust.service # Trust service
			enableApp com.android.certinstaller # Certificate installer
			disableApp com.oculus.os.vrlockscreen # VR lockscreen
			enableApp android.ext.services # Android extension services
			enableApp com.oculus.preloader # Preloader
			enableApp com.android.wifi.resources # Wi-Fi resources
			enableApp com.android.wifi.dialog # Wi-Fi dialog
			enableApp com.android.captiveportallogin # Captive portal login
			disableApp com.oculus.mrds # MRDS (Mixed Reality Debug)
			enableApp com.android.sdksandbox # SDK sandbox
			disableApp com.meta.transport # Transport service
			disableApp com.oculus.socialplatform # Social platform
			disableApp com.oculus.vrosconfigwriterdeprecated # VR OS config writer
			disableApp com.oculus.firsttimenux # First-time setup
			enableApp com.android.providers.settings # Settings provider
			disableApp com.oculus.preshutdowntaskservice # Pre-shutdown tasks
			enableApp oculus.platform # Oculus platform
			disableApp com.facebook.spatial_persistence_service # Spatial persistence service
			enableApp com.android.location.fused # Fused location provider
			enableApp com.android.vpndialogs # VPN dialog
			enableApp com.android.uwb.resources # UWB (Ultra-wideband) resources
			disableApp com.oculus.bodyapiservice # Body tracking APIs
			# disableApp com.meta.handseducationmodule # Hand tracking education
			enableApp com.android.ondevicepersonalization.services # On-device personalization
			enableApp com.android.htmlviewer # HTML viewer
			disableApp com.oculus.notification_proxy # Notification proxy
			disableApp horizon.platform.service.notification # Horizon notification service
			disableApp com.oculus.quickpromotionservice # Quick promotion service
			enableApp com.oculus.systemux # System UX
			disableApp com.oculus.os.chargecontrol # Charge control service
			disableApp com.facebook.wearable.system.location.service # Wearable location service
			disableApp com.oculus.avatareditor # Avatar editor
			enableApp com.oculus.presence # Presence service
			enableApp com.android.providers.userdictionary # User dictionary
			enableApp com.android.cts.ctsshim # CTS test shim
			enableApp com.android.bluetooth # Bluetooth service
			enableApp com.android.storagemanager # Storage manager
			disableApp com.oculus.magicislandcastingservice # Magic Island casting
			enableApp com.android.packageinstaller # Package installer
			enableApp com.android.soundpicker # Sound picker
			enableApp com.android.provision # Device provisioning
			enableApp com.android.hotspot2.osulogin # Hotspot 2.0 login
			disableApp com.oculus.linefrequencyservice # Line frequency service
			enableApp com.android.externalstorage # External storage
			disableApp com.oculus.appautomation # App automation
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
