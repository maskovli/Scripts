<#
.SYNOPSIS
Activates selected Azure AD Privileged Identity Management (PIM) roles for a specified duration.

.DESCRIPTION
This PowerShell script connects to Azure AD and prompts the user to select one or more PIM roles to activate. The selected roles are then activated with a specified duration and justification.

.NOTES
Author: Marius A. Skovli
Date: April 3, 2023
#>

# Check if AzureADPreview module is installed and install if not
if (-not (Get-Module -Name AzureADPreview -ListAvailable)) {
    Write-Verbose "AzureADPreview module is not installed. Installing..."
    Install-Module -Name AzureADPreview -AllowClobber -Force
}

# Import AzureADPreview module
Write-Verbose "Importing AzureADPreview module..."
Import-Module -Name AzureADPreview

# Connect to Azure AD
Connect-AzureAD

# Get available roles and prompt the user to choose one or more
$availableRoles = Get-AzureADMSPrivilegedRoleAssignment -All $true
Write-Host "Available roles:"
$availableRoles | Select-Object -Property DisplayName, Id
$selectedRoleIds = Read-Host "Enter comma-separated role Ids to activate"

# Get the duration for which the role should be active
$duration = Read-Host "Enter the duration for which the role should be active in minutes"

# Get the justification for the activation
$justification = Read-Host "Enter a justification for the activation"

# Activate the selected roles
foreach ($roleId in $selectedRoleIds.Split(',')) {
    $result = Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $roleId -RoleDefinitionId $roleId -Type 'adminAdd' -AssignmentState 'Active' -Duration ($duration) -Reason $justification
    Write-Host "Activated role with Id: $roleId"
}
