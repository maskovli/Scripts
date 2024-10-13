# Define the registry path and key details
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
$RegistryKey = "RestrictDriverInstallationToAdministrators"
$DesiredValue = 0

# Function to detect the current registry setting
function Get-RegistryValue {
    param (
        [string]$Path,
        [string]$Name
    )

    if (Test-Path $Path) {
        try {
            $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
            return $currentValue.$Name
        } catch {
            return $null
        }
    } else {
        return $null
    }
}

# Check the current value
$currentValue = Get-RegistryValue -Path $RegistryPath -Name $RegistryKey

# Compare and output result
if ($currentValue -ne $DesiredValue) {
    Write-Output "Not Compliant"
    exit 1
} else {
    Write-Output "Compliant"
    exit 0
}
