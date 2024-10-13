<#
    Author: Marius A. Skovli
    Company: https://spirhed.com
    Date: 2024-06-14
    Description: This script detects the presence of unnecessary pre-installed applications on Windows 11 devices. No warranty is provided with this script. Use at your own risk.
#>

# List of apps to check
$appsToCheck = @(
    "MicrosoftTeams",                       # Teams Personal
    "Microsoft.XboxApp",                    # Xbox App
    "Microsoft.XboxGamingOverlay",          # Xbox Game Overlay
    "Microsoft.XboxGameCallableUI",         # Xbox Game Callable UI
    "Microsoft.XboxIdentityProvider",       # Xbox Identity Provider
    "Microsoft.Xbox.TCUI",                  # Xbox TCUI
    "Microsoft.YourPhone",                  # Your Phone
    "Microsoft.ZuneMusic",                  # Groove Music
    "Microsoft.ZuneVideo",                  # Movies & TV
    "Microsoft.Microsoft3DViewer",          # 3D Viewer
    "Microsoft.MicrosoftOfficeHub",         # Office Hub
    "Microsoft.GetHelp",                    # Get Help
    "Microsoft.Getstarted",                 # Get Started
    "Microsoft.MicrosoftSolitaireCollection", # Solitaire Collection
    "Microsoft.People",                     # People
    "Microsoft.BingWeather",                # Weather
    "Microsoft.MicrosoftStickyNotes",       # Sticky Notes
   # "Microsoft.MSPaint",                    # Paint
    "Microsoft.MicrosoftWhiteboard",        # Whiteboard
    "Microsoft.OneConnect",                 # Mobile Plans
    "Microsoft.SkypeApp",                   # Skype
    "Microsoft.ScreenSketch",               # Snip & Sketch
    "Microsoft.MixedReality.Portal"         # Mixed Reality Portal
)

$foundApps = @()
foreach ($app in $appsToCheck) {
    $installedApp = Get-AppxPackage -Name $app -AllUsers
    if ($installedApp) {
        $foundApps += $installedApp.Name
    }
}

if ($foundApps.Count -gt 0) {
    Write-Output "Found"
} else {
    Write-Output "Not Found"
}
