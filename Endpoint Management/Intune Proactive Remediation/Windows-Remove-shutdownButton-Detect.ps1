# Define the registry paths and key details
$RegistryPaths = @(
    @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"; Key = "value"; DesiredValue = 1},
    @{Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep"; Key = "value"; DesiredValue = 1}
)

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

# Initialize compliance status
$compliant = $true

# Check each registry value
foreach ($reg in $RegistryPaths) {
    $currentValue = Get-RegistryValue -Path $reg.Path -Name $reg.Key
    if ($currentValue -ne $reg.DesiredValue) {
        $compliant = $false
        Write-Output "Not Compliant: $($reg.Path)\$($reg.Key)"
    }
}

# Output the compliance status
if ($compliant) {
    Write-Output "Compliant"
    exit 0
} else {
    Write-Output "Not Compliant"
    exit 1
}
