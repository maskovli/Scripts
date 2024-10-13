<#
    Author: Marius A. Skovli
    Company: https://spirhed.com
    Date: 2024-06-14
    Description: This script removes unnecessary pre-installed applications from Windows 11 devices. No warranty is provided with this script. Use at your own risk.
#>

# List of apps to remove
$appsToRemove = @(
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
    #"Microsoft.MSPaint",                    # Paint
    "Microsoft.MicrosoftWhiteboard",        # Whiteboard
    "Microsoft.OneConnect",                 # Mobile Plans
    "Microsoft.SkypeApp",                   # Skype
    "Microsoft.ScreenSketch",               # Snip & Sketch
    "Microsoft.MixedReality.Portal"         # Mixed Reality Portal
)

foreach ($app in $appsToRemove) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "$app*"} | Remove-AppxProvisionedPackage -Online
}

# Optional: Remove leftover folders from Program Files if necessary
$foldersToRemove = @(
    "C:\Program Files\WindowsApps\MicrosoftTeams*",
    "C:\Program Files\WindowsApps\Microsoft.XboxApp*",
    "C:\Program Files\WindowsApps\Microsoft.XboxGamingOverlay*",
    "C:\Program Files\WindowsApps\Microsoft.XboxGameCallableUI*",
    "C:\Program Files\WindowsApps\Microsoft.XboxIdentityProvider*",
    "C:\Program Files\WindowsApps\Microsoft.Xbox.TCUI*",
    "C:\Program Files\WindowsApps\Microsoft.YourPhone*",
    "C:\Program Files\WindowsApps\Microsoft.ZuneMusic*",
    "C:\Program Files\WindowsApps\Microsoft.ZuneVideo*",
    "C:\Program Files\WindowsApps\Microsoft.Microsoft3DViewer*",
    "C:\Program Files\WindowsApps\Microsoft.MicrosoftOfficeHub*",
    "C:\Program Files\WindowsApps\Microsoft.GetHelp*",
    "C:\Program Files\WindowsApps\Microsoft.Getstarted*",
    "C:\Program Files\WindowsApps\Microsoft.MicrosoftSolitaireCollection*",
    "C:\Program Files\WindowsApps\Microsoft.People*",
    "C:\Program Files\WindowsApps\Microsoft.BingWeather*",
    "C:\Program Files\WindowsApps\Microsoft.MicrosoftStickyNotes*",
   # "C:\Program Files\WindowsApps\Microsoft.MSPaint*",
    "C:\Program Files\WindowsApps\Microsoft.MicrosoftWhiteboard*",
    "C:\Program Files\WindowsApps\Microsoft.OneConnect*",
    "C:\Program Files\WindowsApps\Microsoft.SkypeApp*",
    "C:\Program Files\WindowsApps\Microsoft.ScreenSketch*",
    "C:\Program Files\WindowsApps\Microsoft.MixedReality.Portal*"
)

foreach ($folder in $foldersToRemove) {
    Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
}
