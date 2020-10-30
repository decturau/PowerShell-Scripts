# Script Created by Declan T
# The purpose of this script is to obtain all iSCSI connections and obtain the Disk, Drive Letter and TargetNodeAddress. This also gives you the option to export to csv. 

#Run this script as administrator (Must be local admin)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Create a function for gathering data
Function GatherInfo {
    # Declare the disk variable so we can get the DiskNumber and Drive Letter
    $Disks=Get-Partition | Select -ExpandProperty DiskNumber

    # Take each disk number and get drive letter and iSCSI conenctions from variables
    Foreach ($disk in $disks) {
	    $Partition= Get-Partition -DiskNumber $Disk
        $ISCSI = Get-Disk -Number $Disk | ?{$_.BusType -Eq "iSCSI"} | Get-IscsiSession 
    
	    # Custom Output based on variables
        [pscustomobject]@{
            DiskNumber=$Partition.DiskNumber -join ''; 
            DriveLetter=($Partition.DriveLetter -join ''); 
            TargetNodeAddress=$ISCSI.TargetNodeAddress -join '';
 
        }  
    }
}

# Clear the screen and promt the user if they wish to export results to csv 
Clear-Host
Write-Host 'You can Export this to CSV. If you select No (default) it will display results in console.' -ForegroundColor Yellow
$Export=Read-Host 'Do you wish to export these results to CSV? (Y/N)'

# If statement based on user input. If Y then it will ask for a path. Anything else will run the script in the console. 
If ($Export -eq "Y") {
    Write-Host 'Filepath MUST BE VALID' -ForegroundColor Yellow 
    $Location=Read-Host 'Enter a Valid Export path (Including Filename). E.g. C:\temp\export.csv' 
    % {Write-Host "Getting your data. Please wait."; GatherInfo | Export-Csv -Path $Location}
    Write-Host 'Complete. Your CSV is in the path you specified, provided it was valid.'
    Read-Host 'Press Enter to Exit'
    }    

Else {
    % {Write-Host "Getting your data. Please wait."; GatherInfo | Out-Host }
    Read-Host 'Press Enter to Exit'
     } 
