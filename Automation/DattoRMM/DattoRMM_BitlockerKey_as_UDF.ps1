<#
.Synopsis
Datto RMM Bitlocker Key as UDF

.Description
Script should be run as a job from Datto RMM. IT will populate a user defined field with the recovery keys. 

.Notes
Author:     Declan Turley   
Version:    1.0
Notes:      Change the [int]$env:usrUDF if you do not want to use UDF 21
Notes:      Recommend to use alongside the bitlocker audit component

#>

# Get Windows 10 Bitlocker encrypted volumes
$EncryptedVolumes=Get-BitLockerVolume | Where-Object {$_.ProtectionStatus -eq "On"} | select -ExpandProperty MountPoint

# Get recovery keys for encrypted volumes
$AllPasswords = Foreach ($Volume in $EncryptedVolumes) {
    (Get-BitLockerVolume -MountPoint $Volume).KeyProtector.RecoveryPassword | Out-String 
}

$AllKeys= $AllPasswords | Out-String
      
# Label your UDF ID as an integer (The UDF can be renamed in Account settings)
[int]$env:usrUDF = '21'

# Validate the UDF Variable 
if ([int]$env:usrUDF -and [int]$env:usrUDF -match '^\d+$') {
    
    # Validate the variable value is between 1 and 30
    if ([int]$env:usrUDF -ge 1 -and [int]$env:usrUDF -le 30) {     
            New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name Custom$env:usrUDF -Value $AllKeys -Force | Out-Null
            write-host "Value written to User-defined Field $env:usrUDF`."
        } 
    else {
        write-host "User-defined Field value must be an integer between 1 and 30."
    }
} else {
    write-host "User-defined field value invalid or not specified - not writing results to a User-defined field."
}




