#Script created by Declan T. 
# The purpose of this script is get all the active VHD or VHDX files for each VM on your local host

#Run this script as administrator (Must be local admin)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Declare Variables
# Obtain all VM names
$VMs=Get-VM | Select -ExpandProperty Name

#Clear screen
Clear-Host

#Get VHD's for each VM on the host
Foreach ($VM in $VMs) {

    #Get each VM and search it for VHD's listing appropiate properties (If attahced, check the parent path)
   % {Write-Host "VHD's for" "$VM" "(if VHD ParentPath is extended, there may be more than one checkpoints)" -ForegroundColor Yellow; Get-VM -Name $VM | Select-Object VMId | Get-VHD | Select $VM,Path,VhdType,FileSize,Size,Attached,ParentPath} | Format-List 
   # Read-Host "Press Enter for Next VM"
 }


