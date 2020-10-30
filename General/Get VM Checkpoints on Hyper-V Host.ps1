# Script created by Declan T. 
# Sript intends to identify all Checkpoints for VM's on a local host

#Run this script as administrator (Must be local admin)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


# Declare Variables
# Obtain all VM names on host
$VMs=Get-VM | Select -ExpandProperty Name

#Clear screen
Clear-Host

#Get checkpoints for each VM on the host
Foreach ($VM in $VMs) {

    #Get each VM and search it for VHD's listing appropiate properties (If attahced, check the parent path)
   % {Write-Host "Getting Checkpoints for " "$VM" -ForegroundColor Yellow; Get-VMcheckpoint -VMname $VM} | Select VMName,Name,CreationTime,Path,ParentCheckpointName | Format-List  
 }

 Write-Host ""
 Write-Host ""
 Write-Host "*******************************"
 Read-Host  "Complete. Press Enter to Exit."


