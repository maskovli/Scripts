# Check if all required modules are installed and install them if necessary
$requiredModules = @('AzureADPreview', 'Az.Accounts')
$missingModules = @()
foreach ($module in $requiredModules) {
    if (-not(Get-Module -Name $module -ErrorAction SilentlyContinue)) {
        $missingModules += $module
    }
}
if ($missingModules.Count -gt 0) {
    Write-Host "The following modules are missing: $($missingModules -join ', '). Installing modules..."
    Install-Module -Name $missingModules -Scope CurrentUser -Force
}

# Import required modules
Import-Module -Name AzureADPreview, Az.Accounts -ErrorAction Stop

# Check if signed in to Azure, prompt to sign in or continue
if (Get-AzContext -ErrorAction SilentlyContinue) {
    $signIn = Read-Host -Prompt "You are already signed in to Azure. Do you want to continue with the current session? Type Y to continue or anything else to sign out and start a new session."
    if ($signIn -ne 'Y') {
        Disconnect-AzAccount
        Connect-AzAccount
    }
} else {
    Connect-AzAccount
}

# Get a list of eligible roles and currently activated roles
$eligibleRoles = Get-AzureADMSPrivilegedRole -All $true -Filter "IsElevatedRole eq true" | Select-Object DisplayName, Description, RoleId
$activatedRoles = Get-AzureADMSPrivilegedRoleAssignment -All $true -Filter "ProviderId eq 'aadRoles' and SubjectId eq '$($env:USERID)'" | Select-Object DisplayName, RoleDefinitionId, AssignmentState, ResourceId, ExpirationTime

# Display the eligible and activated roles
Write-Host "The following are your eligible roles:"
$eligibleRoles | Format-Table -AutoSize
Write-Host "The following roles are currently activated:"
$activatedRoles | Format-Table -AutoSize

# Prompt for roles to activate, justification, and duration, and then activate those roles
$roleSelection = Read-Host -Prompt "Enter the RoleId(s) you want to activate separated by a comma (',')."
$justification = Read-Host -Prompt "Enter the justification for activating the role(s)."
$duration = Read-Host -Prompt "Enter the duration in minutes for which you want to activate the role(s)."

$roleIds = $roleSelection -split ','
foreach ($roleId in $roleIds) {
    $assignment = New-Object -TypeName Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRoleAssignment
    $assignment.ResourceId = $roleId
    $assignment.RoleDefinitionId = $roleId
    $assignment.PrincipalId = $env:USERID
    $assignment.PrincipalType = "User"
    $assignment.Reason = $justification
    $assignment.Duration = [System.TimeSpan]::FromMinutes($duration)
    $assignment = New-AzureADMSPrivilegedRoleAssignment -PrivilegedRoleAssignment $assignment
    Write-Host "Activated role $($assignment.DisplayName) with ID $($assignment.RoleDefinitionId) until $($assignment.ExpirationTime)"
}

# Verify activated roles
$activatedRoles = Get-AzureADMSPrivilegedRoleAssignment -All $true -Filter "ProviderId eq 'aadRoles' and SubjectId eq '$($env:USERID)'" | Select-Object DisplayName, RoleDefinitionId, AssignmentState, ResourceId, ExpirationTime
Write-Host "The following roles are currently activated:"
$activatedRoles | Format