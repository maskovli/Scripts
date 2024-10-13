 
<# Update Windows Autopilot Devices via Microsoft Graph API

 Description:
 This PowerShell script automates the process of updating the Group Tag for multiple Windows Autopilot devices using the Microsoft Graph API.
 It allows you to select devices from a grid view, enter a new Group Tag once, and applies it to all selected devices.
 After updating the devices, it triggers an Autopilot sync to apply the changes.

 Prerequisites:
 - An Azure AD application with the following Microsoft Graph API permissions:
   - DeviceManagementServiceConfig.ReadWrite.All
   - DeviceManagementManagedDevices.ReadWrite.All
 - Tenant ID, Client ID, and Client Secret for the Azure AD application.
 - PowerShell 5.1 or higher.
 - Internet connectivity to access https://graph.microsoft.com.
 - Execution policy set to allow script execution (e.g., RemoteSigned).

 Usage Instructions:
 1. Run the script in PowerShell.
 2. When prompted, enter your Tenant ID, Client ID, and Client Secret.
    - The Client Secret is entered securely and will not be displayed on the screen.
 3. A grid view window will appear displaying all Autopilot devices.
    - Select one or more devices you wish to update and click OK.
 4. When prompted, enter the new Group Tag to be applied to the selected devices.
 5. The script will update the devices and trigger an Autopilot sync.

 Notes:
 - The script uses beta endpoints of the Microsoft Graph API.
   - Beta APIs are subject to change and should be used with caution in production environments.
 - Ensure that the Azure AD application has been granted admin consent for the required permissions.
 - Test the script in a non-production environment before running it in production.

 Version: 1.0
 Author: Marius A. Skovli, Spirhed Group
 Date: October 7, 2024
 http://spirhed.com

#>

# Function to securely get credentials
function Get-SecureCredential {
    param (
        [string]$CredentialName
    )
    return Read-Host -Prompt "Enter your $CredentialName" -AsSecureString
}

# Function to get an access token
function Get-AccessToken {
    param (
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $authUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    $body = @{
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $ClientId
        client_secret = $ClientSecret
    }

    try {
        $response = Invoke-RestMethod -Method Post -Uri $authUrl -ContentType "application/x-www-form-urlencoded" -Body $body
        return $response.access_token
    }
    catch {
        Write-Host "Error obtaining access token: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Function to fetch all Autopilot devices
function Get-AutopilotDevices {
    param (
        [string]$AccessToken
    )

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type'  = 'application/json'
    }

    $devices = @()
    $url = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities"
    do {
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            $devices += $response.value
            $url = $response.'@odata.nextLink'
        }
        catch {
            Write-Host "Error fetching devices: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } while ($url)

    return $devices
}

# Function to update device properties
function Update-DeviceProperties {
    param (
        [string]$AccessToken,
        [object]$Device,
        [string]$NewGroupTag
    )

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type'  = 'application/json'
    }

    $requestBody = @{
        groupTag = $NewGroupTag
    } | ConvertTo-Json

    $updateUrl = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($Device.id)/updateDeviceProperties"

    try {
        Invoke-RestMethod -Uri $updateUrl -Headers $headers -Method Post -Body $requestBody -ContentType 'application/json'
        Write-Host "Successfully updated device: $($Device.displayName) ($($Device.serialNumber))" -ForegroundColor Green
        return $true
    }
    catch {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        if ($errorResponse) {
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Error updating device $($Device.displayName): $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
        }
        else {
            Write-Host "Error updating device $($Device.displayName): $($_.Exception.Message)" -ForegroundColor Red
        }
        return $false
    }
}

# Function to trigger Autopilot sync
function Trigger-AutopilotSync {
    param (
        [string]$AccessToken
    )

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type'  = 'application/json'
    }

    $syncUrl = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotSettings/sync"

    try {
        Invoke-RestMethod -Uri $syncUrl -Headers $headers -Method Post
        Write-Host "Autopilot sync successfully triggered." -ForegroundColor Green
    }
    catch {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        if ($errorResponse) {
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Error during sync: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
        }
        else {
            Write-Host "Error during sync: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Main script execution

# Securely obtain credentials
$tenantId = Read-Host -Prompt "Enter your Tenant ID"
$clientId = Read-Host -Prompt "Enter your Client ID"
$clientSecretSecure = Get-SecureCredential -CredentialName "Client Secret"
$clientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecretSecure))

# Get access token
$accessToken = Get-AccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

# Fetch all Autopilot devices
$autopilotDevices = Get-AutopilotDevices -AccessToken $accessToken

# Check if devices were fetched
if (-not $autopilotDevices) {
    Write-Host "No Autopilot devices found." -ForegroundColor Yellow
    exit 0
}

# Prepare devices for display
$devicesToDisplay = $autopilotDevices | Select-Object -Property id, displayName, model, manufacturer, orderIdentifier, groupTag, enrollmentState, serialNumber

# Show the grid view and allow multiple selection
$selectedDevices = $devicesToDisplay | Out-GridView -OutputMode Multiple -Title "Select devices to update"

# Check if any devices were selected
if (-not $selectedDevices) {
    Write-Host "No devices selected. Exiting script." -ForegroundColor Yellow
    exit 0
}

# Prompt for new group tag with validation
do {
    $newGroupTag = Read-Host -Prompt "Enter the new Group Tag for the selected devices"
    if ([string]::IsNullOrWhiteSpace($newGroupTag)) {
        Write-Host "Group Tag cannot be empty. Please enter a valid Group Tag." -ForegroundColor Yellow
    }
} while ([string]::IsNullOrWhiteSpace($newGroupTag))

# Process selected devices
foreach ($device in $selectedDevices) {
    # Update device properties
    $updateSuccess = Update-DeviceProperties -AccessToken $accessToken -Device $device -NewGroupTag $newGroupTag

    # Optionally, you can choose to break the loop if an update fails
    # if (-not $updateSuccess) { break }
}

# Trigger Autopilot sync after all updates
Trigger-AutopilotSync -AccessToken $accessToken 
