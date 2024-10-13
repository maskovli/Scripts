# Define the registry path and key details
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
$RegistryKey = "RestrictDriverInstallationToAdministrators"
$DesiredValue = 0

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

# Set the registry value
Set-RegistryValue -Path $RegistryPath -Name $RegistryKey -Value $DesiredValue
Write-Output "Registry value set to $DesiredValue"
exit 0
