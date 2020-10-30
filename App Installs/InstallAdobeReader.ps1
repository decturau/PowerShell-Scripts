#Local file path for saving files 
$LocalPath = $env:TEMP

#FTP folder for Adobe installers and patches
$AdobeFTP = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/"

#The installer for adobe. This is for version 1902120058
$InstallerFTP="ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1902120058/AcroRdrDC1902120058_en_US.exe"


#Connect to Adobe URL and get directory listings 
$FTPRequest = [System.Net.FtpWebRequest]::Create("$AdobeFTP") 
$FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
$FTPResponse = $FTPRequest.GetResponse()
$ResponseStream = $FTPResponse.GetResponseStream()
$FTPReader = New-Object System.IO.Streamreader -ArgumentList $ResponseStream
$List = $FTPReader.ReadToEnd()

#Get the most recent patch (Skip misc folder)
$LatestPatch = $List -split '[\r\n]' | Where {$_} | Select -Last 1 -Skip 1

#File name for patch
$PatchFile = "AcroRdrDCUpd" + $LatestPatch + '.msp'

#Patch download URL
$PatchURL = "$AdobeFTP$LatestPatch/$PatchFile"

# Check if Adobe Reader is installed
$AdobeInstalled= Test-Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"

IF ($AdobeInstalled -eq $True){
        Write-Host 'Adobe is installed already installed' -ForegroundColor Green
                                }

Else {
        Write-Host 'Adobe is not installed ' -ForegroundColor Yellow
        
        Clear-Host
        # Downlaod installer files
        Write-Host 'Downloading Adobe Installer' -ForegroundColor Yellow
        Invoke-WebRequest $InstallerFTP -OutFile $LocalPath\Adobe_Installer.exe

        # Install Adobe
        Write-Host 'Installing Adobe' -ForegroundColor Yellow
        cd $LocalPath
        .\Adobe_Installer.exe /sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES

        #Pause for 5 mins for install before installing patch
        Write-Host 'Waiting for 5 minutes' -ForegroundColor Yellow
        Start-Sleep 300

}
