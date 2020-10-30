# Script Cretaed by Declan T
# Script is intended to get the Windows Verson via PowerShell based on the build number. 

$Build=[System.Environment]::OSVersion.Version.Build 
$Version=[System.Environment]::OSVersion.Version
$hostname=Hostname

Clear-Host
IF ($Build -eq '10240') 
    {
    write-host 'Windows version for' $hostname 'is 1507'
    }

elseif ($Build -eq '10586') 
     {
     write-host 'Windows version for' $hostname 'is 1511'
     }

elseif ($Build -eq '14393') 
     {
     write-host 'Windows version for' $hostname 'is 1607'
     }

elseif ($Build -eq '15063') 
     {
     write-host 'Windows version for' $hostname 'is 1703'
     }

elseif ($Build -eq '16299') 
     {
     write-host 'Windows version for'$hostname 'is 1709'
     }

elseif ($Build -eq '17134') 
     {
     write-host 'Windows version for' $hostname 'is 1803'
     }

elseif ($Build -eq '17763') 
     {
     write-host 'Windows version for' $hostname 'is 1809'
     }

elseif ($Build -eq '18362') 
     {
     write-host 'Windows version for' $hostname 'is 1903'
     }

elseif ($Build -eq '18363') 
     {
     write-host 'Windows version for' $hostname 'is 1909'
     }

elseif ($Build -eq '19041') 
     {
     write-host 'Windows version for' $hostname 'is 2004'
     }
elseif ($Build -eq '19042') 
     {
     write-host 'Windows version for' $hostname 'is 20H2'
     }
Else {Write-host 'Windows Version for' $hostname 'is' $Version}
