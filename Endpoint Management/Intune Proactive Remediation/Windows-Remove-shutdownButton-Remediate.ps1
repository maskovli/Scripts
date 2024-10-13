# Define the registry paths and key details
$RegistryPaths = @(
    @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"; Key = "value"; DesiredValue = 1},
    @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep"; Key = "value"; DesiredValue = 1}
)

# Function to set the registry value
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

# Set each registry value
foreach ($reg in $RegistryPaths) {
    Set-RegistryValue -Path $reg.Path -Name $reg.Key -Value $reg.DesiredValue
    Write-Output "Registry value set: $($reg.Path)\$($reg.Key) = $($reg.DesiredValue)"
}

# Exit script with success code
exit 0
