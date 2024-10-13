
<#


Turn off Windows Network Connectivity Status Indicator active tests
This policy setting turns off the active tests performed by the Windows Network Connectivity Status Indicator (NCSI) to determine whether your computer is connected to the Internet or to a more limited network.

As part of determining the connectivity level, NCSI performs one of two active tests: downloading a page from a dedicated Web server or making a DNS request for a dedicated address.

If you enable this policy setting, NCSI does not run either of the two active tests. This may reduce the ability of NCSI, and of other components that use NCSI, to determine Internet access.

If you disable or do not configure this policy setting, NCSI runs one of the two active tests.

https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.InternetCommunicationManagement::NoActiveProbe

#>


# Step 1: Modify EnableActiveProbing to 0
$regPath1 = "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet"
$regValueName1 = "EnableActiveProbing"
$regValueData1 = 0

# Check if the registry key exists, if not, create it
if (-not (Test-Path $regPath1)) {
    New-Item -Path $regPath1 -Force | Out-Null
}

# Set the registry value to disable active probing
Set-ItemProperty -Path $regPath1 -Name $regValueName1 -Value $regValueData1 -Type DWord

Write-Output "Set EnableActiveProbing to 0."

# Step 2: Modify NoActiveProbe to 1
$regPath2 = "HKLM:\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator"
$regValueName2 = "NoActiveProbe"
$regValueData2 = 1

# Check if the registry key exists, if not, create it
if (-not (Test-Path $regPath2)) {
    New-Item -Path $regPath2 -Force | Out-Null
}

# Set the registry value to disable NCSI active probing
Set-ItemProperty -Path $regPath2 -Name $regValueName2 -Value $regValueData2 -Type DWord

Write-Output "Set NoActiveProbe to 1."

# Step 3: Modify DisablePassivePolling to 1
$regValueName3 = "DisablePassivePolling"
$regValueData3 = 1

# Set the registry value to disable passive polling
Set-ItemProperty -Path $regPath2 -Name $regValueName3 -Value $regValueData3 -Type DWord

Write-Output "Set DisablePassivePolling to 1."

# Output the completion message
Write-Output "Registry settings have been successfully updated."