<#	
	.NOTES
	===========================================================================
	 Created on:   	13.05.2019
	 Created by:   	Marius A. Skovli
	 Filename:     	
	===========================================================================
	.DESCRIPTION
        Run script section by section.
        TIP: Add the autounattend.xml to the ISO in order to automate the process entierly. 
#>



<#
Set the Variables needed for the operation
#>

$LabVMName = "SH-CLIENT-05-PersonalEnv"
$LabVMPath = "D:\VMs\$LabVMName"
$Time = "Get-Date"
$ISO = "D:\iso\en-us_windows_11_business_editions_updated_may_2022_x64_dvd_f6700d97.iso"
$Switch = "vLAN"

<#
Create the VMs
#>

New-VM -Name $LabVMName -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath "$LabVMPath\Virtual Hard Disks\$LabVMName.vhdx" -Path "C:\VMs\$LabVMName\Virtual Machines" -NewVHDSizeBytes 80GB -Generation 2 -Switch "Default switch" -Verbose
Set-VM -Name $LabVMName -ProcessorCount 4 -AutomaticCheckpointsEnabled $False -SnapshotFileLocation "$LabVMPath\Snapshots" -Verbose
Add-VMDvdDrive -Path $ISO -VMName $LabVMName -Verbose
Get-VMNetworkAdapter -VMName $LabVMName | Connect-VMNetworkAdapter -SwitchName $Switch

<#
Enable Security features and other settings

$owner = Get-HgsGuardian UntrustedGuardian
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
Set-VMKeyProtector -VMName $LabVMName -KeyProtector $kp.RawData
Enable-VMTPM -VMName $LabVMName

#>
Set-VMKeyProtector -VMName $LabVMName -NewLocalKeyProtector -Verbose
Enable-VMTPM -VMName $LabVMName -Verbose

<#
Set boot order to DVD Drive
#>

#Get-VMFirmware $LabVMName
$win10g2 = Get-VMFirmware $LabVMName
$win10g2.bootorder
$hddrive = $win10g2.BootOrder[0]
$pxe = $win10g2.BootOrder[1]
$dvddrive = $win10g2.BootOrder[2]
Set-VMFirmware -VMName $LabVMName -BootOrder $dvddrive,$hddrive,$pxe -Verbose

<#
Start the VM and connect to the console
#>

vmconnect.exe localhost $LabVMName
Start-VM -VMName $LabVMName -Verbose

#Checkpoint-VM -VMName $LabVMName -SnapshotName "$LabVMName-$Time"
