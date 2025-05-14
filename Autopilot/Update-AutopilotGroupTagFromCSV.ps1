<# Update Windows Autopilot Devices via Microsoft Graph API (CSV‑Driven / File‑Picker)

 Description:
 This PowerShell script updates the **Group Tag** for multiple Windows Autopilot devices using a CSV file containing ONLY device identifiers (SerialNumber *or* Id).  
 It pops a Windows file‑picker for the CSV and prompts (securely) once for the Group Tag.

 CSV Requirements:
   • **SerialNumber** *or* **Id** header – at least one.  
   • No **GroupTag** column; the tag is supplied interactively.
   • No comment lines (the `#` example in the docs was illustrative, not literal).

 Version: 2.2  |  Author: Marius A. Skovli  |  Date: May 14 2025
#>

#region Helper Functions
function Get-SecureInput {
    param([string]$Prompt)
    Write-Host "$Prompt" -NoNewline
    Read-Host -AsSecureString
}

function ConvertFrom-SecureStringPlain {
    param([SecureString]$Secure)
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([
        Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure))
}

function Get-AccessToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecretPlain
    )
    # Trim any stray whitespace or line‑breaks
    $TenantId          = $TenantId.Trim()
    $ClientId          = $ClientId.Trim()
    $ClientSecretPlain = $ClientSecretPlain.Trim()

    $authUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    $body = @{
        grant_type    = 'client_credentials'
        scope         = 'https://graph.microsoft.com/.default'
        client_id     = $ClientId
        client_secret = $ClientSecretPlain
    }
    try {
        (Invoke-RestMethod -Method Post -Uri $authUrl -ContentType 'application/x-www-form-urlencoded' -Body $body).access_token
    } catch {
        Write-Error "Failed to obtain access token – double‑check Tenant ID / Client ID / Secret. $_"
        exit 1
    }
}

function Get-AutopilotDevices {
    param([string]$AccessToken)
    $headers = @{ Authorization = "Bearer $AccessToken" }
    $url = 'https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities'
    $data = @()
    do {
        $r = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        $data += $r.value
        $url = $r.'@odata.nextLink'
    } while ($url)
    $data
}

function Update-Device {
    param(
        [string]$AccessToken,
        [object]$Device,
        [string]$GroupTag
    )
    $headers = @{ Authorization = "Bearer $AccessToken"; 'Content-Type'='application/json' }
    $body = @{ groupTag = $GroupTag } | ConvertTo-Json
    $url = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($Device.id)/updateDeviceProperties"
    try {
        Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body | Out-Null
        Write-Host "✓ $($Device.serialNumber) → '$GroupTag'" -ForegroundColor Green
        $true
    } catch {
        Write-Host "✗ $($Device.serialNumber): $($_.Exception.Message)" -ForegroundColor Red
        $false
    }
}

function Trigger-AutopilotSync {
    param([string]$AccessToken)
    $headers = @{ Authorization = "Bearer $AccessToken" }
    Invoke-RestMethod -Uri 'https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotSettings/sync' -Headers $headers -Method Post | Out-Null
    Write-Host 'Autopilot sync triggered.' -ForegroundColor Cyan
}
#endregion

#region Gather Credentials
$tenantId         = (Read-Host -Prompt 'Tenant ID').Trim()
$clientId         = (Read-Host -Prompt 'Client ID').Trim()
$clientSecret     = Get-SecureInput 'Client Secret: '
$clientSecretText = ConvertFrom-SecureStringPlain $clientSecret
#endregion

#region CSV File‑Picker
Add-Type -AssemblyName System.Windows.Forms
$ofd = New-Object System.Windows.Forms.OpenFileDialog
$ofd.Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
$ofd.Title  = 'Select the CSV containing Autopilot device identifiers'
if ($ofd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host 'No file selected. Exiting.' -ForegroundColor Yellow; exit 0
}
$csvPath = $ofd.FileName
#endregion

#region Group Tag Prompt
$groupTagSecure = Get-SecureInput 'New Group Tag: '
$groupTag       = ConvertFrom-SecureStringPlain $groupTagSecure
if ([string]::IsNullOrWhiteSpace($groupTag)) { Write-Host 'Group Tag cannot be blank.' -ForegroundColor Red; exit 1 }
#endregion

#region Main Logic
$token = Get-AccessToken -TenantId $tenantId -ClientId $clientId -ClientSecretPlain $clientSecretText
$inventory = Get-AutopilotDevices -AccessToken $token
if (-not $inventory) { Write-Host 'No Autopilot devices found.'; exit 0 }

$csvData = Import-Csv -Path $csvPath
if (-not $csvData) { Write-Host 'CSV is empty.' -ForegroundColor Red; exit 1 }

$ok = 0; $fail = 0
foreach ($row in $csvData) {
    $identifier = if ($row.Id) { $row.Id.Trim() } elseif ($row.SerialNumber) { $row.SerialNumber.Trim() } else { '' }
    if (-not $identifier) { Write-Host 'Row missing Id/SerialNumber – skipping.' -ForegroundColor DarkYellow; $fail++; continue }

    $device = $inventory | Where-Object { ($_.id -eq $identifier) -or ($_.serialNumber -eq $identifier) } | Select-Object -First 1
    if (-not $device) { Write-Host "Device '$identifier' not found." -ForegroundColor DarkYellow; $fail++; continue }

    if (Update-Device -AccessToken $token -Device $device -GroupTag $groupTag) { $ok++ } else { $fail++ }
}

Write-Host "`nSummary: $ok succeeded, $fail failed." -ForegroundColor Magenta
if ($ok -gt 0) { Trigger-AutopilotSync -AccessToken $token }
#endregion
 
