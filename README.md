# FreeXR OS

AOSP Pseudo-ROM for QFPROM-fused standalone XR devices to hijack the control over your device back to your hands.

## Features

Global:
  * Debloater - Removes all software, but those needed for minimal UI functionality
  * Liberator - Replaces proprietary applications with open-source alternatives
  * Rebrander[WIP] - Replaces the vendor's branding with a custom one

Device-Specific:
  * Vendor/Meta:
    * Disable Firmware Updates
    * Disables Telemetry[WIP]
    * Enables META Store with anonymization mitigations
  * Eureka:
    * Attempts permanently root of the Device via Event Horizon
    * Force-Enables Hand Tracking
  * Panther
    * Attempts permanently root of the Device via Event Horizon
    * Force-Enables Hand Tracking

# Contributions

The project is currently under heavy development code improvements are always welcome, but new features have to be brainstormed to be mergable.

The nix daemon is recommended to interface with the repository.

## Tree

├── **docs** -- Various documents for the source code<br/>
├── **src** -- The Source Code<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **lib** -- Shell Libraries used by the program<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **standalone** -- Standalone scripts that can be sourced as libraries<br/>
├── **tasks** -- Routines to work with the project<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **docs** -- Tasks related to the project documentation<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **tree** -- Task used to generate this file hierarchy output<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **editors** -- Nix definition for repository-standardized editors<br/>
├── **vendor** -- Files from 3rd party used in the project<br/>
