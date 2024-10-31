<#
.SYNOPSIS
    Detection script for Microsoft Teams Personal installation using AppX commands.

.DESCRIPTION
    This script checks whether Microsoft Teams Personal is installed on a Windows 11 device
    by searching for the MicrosoftTeams AppX package across all user profiles. It returns a
    non-zero exit code if the package is detected, indicating non-compliance.

.AUTHOR
    Marius A. Skovli
    Spirhed Group
    https://spirhed.com

.DATE
    2024-10-9

.VERSION
    1.1

#>

# Enable strict mode for better error handling
Set-StrictMode -Version Latest

# Function to check if Microsoft Teams Personal is installed
function Test-TeamsPersonalInstalled {
    try {
        # Retrieve all instances of the MicrosoftTeams AppX package for all users
        $teamsPackages = Get-AppxPackage -Name MicrosoftTeams -AllUsers -ErrorAction SilentlyContinue

        if ($teamsPackages) {
            Write-Output "Microsoft Teams Personal is installed."
            return $true
        }
        else {
            Write-Output "Microsoft Teams Personal is not installed."
            return $false
        }
    }
    catch {
        Write-Error "An error occurred while checking for Microsoft Teams Personal: $_"
        return $false
    }
}

# Execute the detection
$teamsInstalled = Test-TeamsPersonalInstalled

if ($teamsInstalled) {
    exit 1  # Non-zero exit code indicates detection (non-compliant)
}
else {
    exit 0  # Zero exit code indicates compliance
}
