# Script created by Declan T. 

# Run this script as the logged on user. If you run as admin you may not have access to the drive maps. 

# Specify your drive exclusions for searching (I.e C drive, DVD drives). Do this in the following format 'C', 'D', 'E'
$Exclusions='C', 'U'

# Get all Mapped Drives - Exlcuding the specified drives above
$MappedDrives=Get-PSDrive -PSProvider FileSystem | Select-Object Name, DisplayRoot | Where-Object Name -notin $Exclusions| Select -ExpandProperty Name

# Search each drive for your specified file types
Clear-Host
Foreach ($MappedDrive in $MappedDrives) {
        $path=$MappedDrive + ":\"
        CD $path

    # Display which drive is being search. If you want to change the file extensions - change this after "-include"
        % {Write-Host "Searching for Virtual Disks in" "$MappedDrive" "Drive" -ForegroundColor Yellow; Get-ChildItem -Include *.vhd, *.vhdx -File -Recurse -ErrorAction SilentlyContinue}
  
 }

 pause
