<#
.SYNOPSIS
    Remediation script to uninstall Microsoft Teams Personal using AppX commands.

.DESCRIPTION
    This script removes Microsoft Teams Personal from a Windows 11 device by executing the
    Remove-AppxPackage cmdlet for the MicrosoftTeams AppX package across all user profiles.
    It ensures silent uninstallation and cleans up residual folders post-removal.

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

# Function to uninstall Microsoft Teams Personal
function Uninstall-TeamsPersonal {
    try {
        # Retrieve all instances of the MicrosoftTeams AppX package for all users
        $teamsPackages = Get-AppxPackage -Name MicrosoftTeams -AllUsers -ErrorAction SilentlyContinue

        if ($teamsPackages) {
            foreach ($package in $teamsPackages) {
                try {
                    Write-Output "Uninstalling Microsoft Teams Personal for User SID: $($package.UserSid)"
                    # Remove the AppX package silently
                    Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Warning "Failed to uninstall Microsoft Teams Personal for User SID: $($package.UserSid). Error: $_"
                }
            }
        }
        else {
            Write-Output "Microsoft Teams Personal is not installed. No action required."
        }
    }
    catch {
        Write-Error "An error occurred while attempting to uninstall Microsoft Teams Personal: $_"
    }
}

# Function to remove residual Teams folders
function Remove-TeamsResidualFolders {
    $teamsFolders = @(
        "$env:ProgramFiles\Microsoft Teams",
        "$env:ProgramFiles(x86)\Microsoft Teams",
        "$env:LocalAppData\Microsoft\Teams",
        "$env:Roaming\Microsoft\Teams"
    )

    foreach ($folder in $teamsFolders) {
        if (Test-Path -Path $folder) {
            try {
                Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
                Write-Output "Removed residual folder: $folder"
            }
            catch {
                Write-Warning "Failed to remove residual folder: $folder. Error: $_"
            }
        }
    }
}

# Execute the uninstallation
Uninstall-TeamsPersonal

# Remove residual folders
Remove-TeamsResidualFolders

Write-Output "Microsoft Teams Personal uninstallation process completed."
exit 0  # Exit with zero to indicate script completion
