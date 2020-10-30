# Script created by Declan T. 
# Declare Variables for save directory, Chrome download URL
$TempDir=$ENV:Temp
$LatestURL= "https://dl.google.com/chrome/install/latest/chrome_installer.exe"

# Check if Chrome is already installed
$ChromeInstalled = Test-Path "C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe"

# If installed, do nothing, if no download and silently install
Clear-Host
If ($ChromeInstalled -eq $True) 
        {Write-Host 'Chrome already installed' -ForegroundColor Yellow}

Else    {
         Write-Host 'Downlaoding Chrome' -ForegroundColor Yellow
         
         # Download latest version of Chrome
         Invoke-WebRequest $LatestURL -OutFile $TempDir\Chrome.exe
         Write-Host 'Installing Chrome' -ForegroundColor Yellow
         
         # Install Chrome Silently
         Start-Process -FilePath $TempDir\Chrome.exe -Args "/silent /install" -Verb RunAs -Wait; 
         
         # Remove install files and log
         Write-Host 'Cleaning up temp files' -ForegroundColor Yellow
         Remove-Item $TempDir\Chrome.exe
         Remove-Item $TempDir\chrome_installer.log 
         
         Write-Host 'Chrome Installed' -ForegroundColor Green          
         }
