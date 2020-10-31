<#
.Synopsis
Get iSCSI targets and their associated drive letter

.Description
Match driver letter with TargetNodeAddress

.Notes
Author:     Declan Turley   
Version:    1.0
#>

#Run this script as administrator (Must be local admin)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Declare the disk variable so we can get the DiskNumber and Drive Letter
$Disks=Get-Partition | Select -ExpandProperty DiskNumber

# Take each disk number and get drive letter and iSCSI conenctions from variables
foreach ($disk in $disks) {
	$Partition= Get-Partition -DiskNumber $Disk
    $ISCSI = Get-Disk -Number $Disk | ?{$_.BusType -Eq "iSCSI"} | Get-IscsiSession 
    
	# Custom Output based on variables
    [pscustomobject]@{
        DiskNumber=$Partition.DiskNumber; 
        DriveLetter=$Partition.DriveLetter; 
        TargetNodeAddress=$ISCSI.TargetNodeAddress;
 
    } | Format-List
}

pause
