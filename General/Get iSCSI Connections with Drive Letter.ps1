# Script Created by Declan T
# The purpose of this script is to obtain all iSCSI connections and obtain the Disk, Drive Letter and TargetNodeAddress

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
