#!/usr/bin/env sh

### DO NOT RUN THIS SCRIPT! EVALUATION AND DEVELOPMENT ONLY! ###

# FreeXR Hijack Script of the META Quest 3 (Eureka) Device, replacing as many packages as possible with open-source alternativesi and removing META/Oculus apps until we figure out how to unlock the bootloader
#
# Tested on Eureka v76, use caution for other firmware versions
#
# Instructions:
# 0.0. Extract META Access Token, Oculus Access Token and deviceKey from horizon app using root on your android phone (no idea how rn)
# 0. Get an Android Phone or Emulator and install Private Quest App (https://xdaforums.com/t/app-5-0-private-quest-vr-headset-management-tool.4695491). We assume private quest 1.3 for this tutorial
# 0.1. Get an ADB-cabable system, ideally linux with adb package
# 1. On Eureka: POWER+VOL_DOWN until the device turns off and bootloader menu appears, then perform factory reset (WARNING: YOU WILL LOSE ALL YOUR DATA!)
# 2. Once eureka boots up, connect to it via private quest:
# 2.1. Private Quest -> Init -> Set DeviceKey
# 2.2. Private Quest -> Config -> Disable OTA -> Get, then turn the toggle to the OFF position.
# 2.3. Private Quest -> Control -> Developer mode -> Get, then turn to ON position
# 2.4. Private Quest -> Control -> ADB -> Get, then turn to ON position
# 2.5. Private Quest -> Init -> Set Oculus token
# 2.6. Private Quest -> Init -> Set Meta token
# 2.7. Private Quest -> Init -> Skip NUX
# 3. The device is now in de-META and de-oculed state as the Oculus and Meta tokens are not set.
# 4. Connect eureka to your computer with ADB and in eureka set always trust
# 5. Run this script
#
# Action plan:
# 0. Disable OTA
# 1. Remove all META/Oculus apps to the point where we have bare minimum device
# 2. Install alternatives
# 3. Sanitize Companion Server
# 4. Include neo store as replacement to meta store including sidequest repositories
# 5. Replace the Library app (launcher) with lightning launcher

set -e # Exit on false return

# --- Functions ---
disable() { adb shell pm disable-user --user 0 "$1" ;} # Disable Package
enable() { adb shell pm enable --user 0 "$1"; } # Enable Package
uninstall() { true;} # Uninstall Package

# --- Prevent OTA Updates ---
disable com.oculus.updater # Disable updates on META Quest Devices

# --- Essential Services for VR Shell (Keep Enabled) ---
enable com.oculus.vrshell # VR Shell itself, essential for VR environment
enable com.oculus.os.vrlockscreen # VR lock screen functionality (important for secure navigation in VR)

# --- Core System Services ---
enable com.android.settings # Basic settings for configuration
enable com.android.networkstack # Core networking stack (important for Wi-Fi, networking)
enable com.android.inputdevices # Input devices (touch, controllers)
enable com.android.keychain # Keychain for secure data management
enable com.android.providers.settings # Stores settings preferences (critical for system setup)
enable com.oculus.panelapp.settings # Quick Settings from bar

# --- Core Oculus Services (Minimal Set) ---
# enable com.oculus.q4bservice # Manages Oculus for Business services (optional based on use case) PROTECTED
# enable com.oculus.vrusb # Manages USB connectivity (important for VR accessories) PROTECTED
enable com.oculus.systemresource # Displays technical system data (useful but not intrusive)

# --- VR Camera Service ---
enable com.oculus.metacam # Required for camera access in VR environments (disabled otherwise)

# --- System Utilities and Miscellaneous ---
disable com.oculus.systemutilities # System utilities (opens files, unnecessary for minimal setup)
disable com.oculus.panelapp.library # Oculus library (not needed for minimal UI)

# --- Disable Meta and Oculus Bloatware ---
disable com.oculus.avatareditor # Avatar editor (doesn’t load without Meta services, unnecessary)
disable com.oculus.identitymanagement.service # Identity management (bloat, not necessary)
disable com.oculus.firsttimenux # First-time setup (you’re skipping this for a minimal setup)
disable com.meta.pclinkservice.server # Oculus Link (disabled as you are using a 3rd party replacement)
disable com.oculus.hzosgallery # VR gallery (not needed)
disable com.oculus.q4b.mdm # Device management (disabled)
disable com.oculus.store # Oculus store (not needed for now)
disable com.oculus.assistant # Voice assistant (disabled)
disable com.oculus.socialplatform # Social services (disabled)
disable com.oculus.explore # Explore app (not required)
disable com.oculus.mrds # Mixed reality (not needed)
disable com.oculus.os.qrcodereader # QR Code reader (fixed package name)

# --- Android Files (Not Required with 3rd Party System) ---
enable com.android.providers.contacts # Contact management (not needed)
enable com.android.providers.media.module # Media module (disabled)
enable com.android.providers.downloads # Download manager
enable com.android.providers.calendar # Calendar (not needed)
enable com.android.shell # Shell (disabled)
enable com.android.externalstorage # External storage (not needed)
enable com.android.captiveportallogin # Captive portal login (not needed)

# --- Miscellaneous Android System Services ---
enable com.android.wifi.resources # Wi-Fi resources (handled by networkstack)
disable com.android.adservices.api # Ad services (disabled)
enable com.android.hotspot2.osulogin # Hotspot login
enable com.android.externalstorage # External storage
enable com.android.keychain # Keychain
enable com.android.permissioncontroller # Permission controller

# --- Services Related to Meta Apps (To Be Disabled) ---
disable com.oculus.horizonmediaplayer # Horizon media player (not needed)
disable com.oculus.presence # Presence (disabled for minimal UI)

# --- Other Non-Essential System Services ---
disable com.oculus.systemactivities # System activities tracking (disabled)
disable com.oculus.quickpromotionservice # Not required
disable com.oculus.externaldisplayservice # External display service (not needed)
disable com.oculus.magicislandcastingservice # VR casting (not needed)
disable com.oculus.os.clearactivity # No clear activity required
disable com.oculus.panelapp.kiosk # Kiosk mode (disabled)
disable com.oculus.deviceauthserver # Device authentication (disabled)

# --- Additional Cleanup ---
disable com.oculus.linefrequencyservice # Line frequency (unnecessary)
disable com.oculus.tv # TV app (unnecessary)

# --- Companion Server ---
# FIXME(Krey): Sanitize Companion Server so that META can't use it as backdoor, likely by decompiling it and replacing it with adjusted app
# disable com.oculus.companion.server # Companion server (protected package, cannot be disabled without root)

# --- Hand Tracking ---
# FIXME(Krey): Make hand tracking to works, at minimal we need the guidebook app and require user interaction to enable these in the quest settings

# --- Neo Store ---
# FIXME(Krey): Install Neo Store as replacement for META Store
# FIXME(Krey): Configure Neo Store to use Tor
# FIXME(Krey): Configure Neo Store to use our f-droid repositories
# FIXME(Krey): Ask SideQuest to provide f-droid repository for their apps

# --- Lightning Launcher ---
# FIXME(Krey): Install Lightning Launcher
# FIXME(Krey): Replace the menu button in systemux to launch lightning launcher

# --- (Optional) META Apps
# FIXME(Krey): Figure out how to make META apps to work in this environment e.g. sandboxing them

# --- Other changes ---
# FIXME(Krey): Remove META app pins from the bottom bar
# FIXME(Krey): Remove horizon app
# FIXME(Krey): Install wivrn as replacement to oculus link
# FIXME(Krey): Enable seamless multitasking
# FIXME(Krey): Install Stremio for META Quest as replacement for META TV and Theater anywhere
# FIXME(Krey): Install OSMAnd as replacement for maps
# FIXME(Krey): Make sure that META can't write killswitch in the required directory 
