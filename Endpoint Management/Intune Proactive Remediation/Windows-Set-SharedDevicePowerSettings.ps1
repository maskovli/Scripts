<#
.SYNOPSIS
This script configures power settings on Windows 11 endpoints.

.DESCRIPTION
This script sets specific power plan settings for Windows 11 machines, including display and sleep configurations, and power button actions. It is designed to be deployed via Intune.

.PARAMETER activeScheme
The GUID of the currently active power scheme. The script retrieves this automatically.

.EXAMPLE
PS> .\SetPowerPlan.ps1
Executes the script to set power configurations.

.NOTES
Author: Marius A. Skovli
Company: Spired AS
Web: http://www.spired.com
Version: 1.0
Date: February 24, 2024
Documentation MSFT: https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options
Documentation Additional: https://www.tenforums.com/tutorials/69741-change-default-action-power-button-windows-10-a.html
#>

# First, we need the GUID of the active power scheme
$activeScheme = (powercfg -getactivescheme).split()[3]

# Set the power plan to High Performance
powercfg -setactive scheme_min

# Set the display timeout for both 'On battery' and 'Plugged in'
powercfg -change monitor-timeout-dc 900
powercfg -change monitor-timeout-ac 900

# Set the computer to never sleep or hibernate for both 'On battery' and 'Plugged in'
powercfg -change standby-timeout-dc 0
powercfg -change standby-timeout-ac 0
powercfg -change hibernate-timeout-dc 0
powercfg -change hibernate-timeout-ac 0

# Set the power button to do nothing for both 'On battery' and 'Plugged in'
powercfg -setacvalueindex $activeScheme SUB_BUTTONS PBUTTONACTION 0
powercfg -setdcvalueindex $activeScheme SUB_BUTTONS PBUTTONACTION 0

# Set the sleep button to do nothing for both 'On battery' and 'Plugged in'
powercfg -setacvalueindex $activeScheme SUB_BUTTONS SBBUTTONACTION 0
powercfg -setdcvalueindex $activeScheme SUB_BUTTONS SBBUTTONACTION 0

# Set the lid close action to do nothing for both 'On battery' and 'Plugged in'
powercfg -setdcvalueindex $activeScheme SUB_BUTTONS LIDACTION 0
powercfg -setacvalueindex $activeScheme SUB_BUTTONS LIDACTION 0

# Configure additional settings based on the GPO image
powercfg -change -monitor-timeout-ac 900
powercfg -change -disk-timeout-ac 0
powercfg -setacvalueindex $activeScheme SUB_VIDEO VIDEOIDLE 10
powercfg -setacvalueindex $activeScheme SUB_DISK DISKIDLE 20

# Configure for battery power
powercfg -change -monitor-timeout-dc 900
powercfg -change -disk-timeout-dc 0
powercfg -setdcvalueindex $activeScheme SUB_VIDEO VIDEOIDLE 5
powercfg -setdcvalueindex $activeScheme SUB_DISK DISKIDLE 5

# Set critical battery action to hibernate
powercfg -setdcvalueindex $activeScheme SUB_BATTERY BATACTIONCRIT 1
powercfg -setacvalueindex $activeScheme SUB_BATTERY BATACTIONCRIT 1

# Set low battery level
powercfg -setdcvalueindex $activeScheme SUB_BATTERY BATLEVELCRIT 5
powercfg -setacvalueindex $activeScheme SUB_BATTERY BATLEVELCRIT 5

# Set low battery notification to off
powercfg -setdcvalueindex $activeScheme SUB_BATTERY BATFLAGSLOW 0
powercfg -setacvalueindex $activeScheme SUB_BATTERY BATFLAGSLOW 0

# Set low battery action to do nothing
powercfg -setdcvalueindex $activeScheme SUB_BATTERY BATACTIONLOW 0
powercfg -setacvalueindex $activeScheme SUB_BATTERY BATACTIONLOW 0
