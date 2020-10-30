# Script Created by Declan T
# The purpose of this script is to obtain all encrypted volumes with bitlocker and show their recovery keys. Valid in Windows 10. 

$EncryptedVolumes = Get-BitLockerVolume | select -ExpandProperty MountPoint
$Hostname= hostname
Foreach ($Volume in $EncryptedVolumes) {
        $RecoveryKey=(Get-BitLockerVolume -MountPoint $Volume).KeyProtector | select -ExpandProperty RecoveryPassword  
        Clear-Host	    
        Write-Host 'Recovery Key for' $hostname 'volume' $volume 'is'$RecoveryKey
}
