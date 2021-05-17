  
<#
.SYNOPSIS
  This script will update the TLS certificate for all Azure AD App Proxy Apps on a particular custom domain. 
.DESCRIPTION
  You should have Application Administrator permissions to run this. A use-case is for updating a new Wildcard certificate across multiple applications.  
   
.NOTES
  Version:        1.0
  Author:         Declan Turley
  Purpose:        Update multiple Apps with new TLS certificate.   

.PARAMETER CustomDomain
The domain linked to the external URL of the application where you wish to update the certificate

.PARAMETER PFXLocation
The location of the new certificate PFX. Includes the file name.

.EXAMPLE
  Update-CustomDomainProxyAppsTLSCertificate.ps1 -CustomDomain domain.com -PFXLocation 'C:\temp\cert.pfx'
#>

Param(
    [Parameter(Mandatory = $true)]
    [string] $CustomDomain,
    [Parameter(Mandatory=$True)]
    [String] $PFXLocation
)

#Enter the PFX password 
Write-Host 'Enter the password for PFX file' -ForegroundColor Yellow
$PFXPassword = Read-Host -AsSecureString

#Connect to AzureAD
Write-Host 'Connecting to AzureAD' -ForegroundColor Yellow
Connect-AzureAD

#Get all Azure AD App Proxy Proxy Applications checking the ObjectID of all apps. 
Write-Host 'Obtaining Azure AD App Proxy Applications for your Domain' -ForegroundColor Yellow
$ProxyApps = foreach ($a in (Get-AzureADApplication -All:$true))
 {
     try
     {
         $p = Get-AzureADApplicationProxyApplication -ObjectId $a.ObjectId
         [pscustomobject]@{ObjectID=$a.ObjectId; DisplayName=$a.DisplayName; ExternalUrl=$p.ExternalUrl; InternalUrl=$p.InternalUrl}
     }
     catch
     {
         continue
     }
}

#Filter the proxy applications with the ExternalURL of your domain 
$AppsOnCustomDomain = $ProxyApps | where {$_.ExternalUrl -like "*$CustomDomain*"}

Write-Host 'The following applications will have their certificate changed' -ForegroundColor Yellow
$AppsOnCustomDomain | Out-Host

Write-Host 'Are you sure you wish to change certificate on the above applications? (Y/N)' -ForegroundColor Yellow
$Answer = Read-Host

If ($Answer -eq 'Y'){
  #Loop through the custom domain apps and upload new TLS certificate 
  foreach ($CustomDomainApp in $AppsOnCustomDomain) {
      Write-Host "Setting Certificate on Application" $CustomDomainApp.DisplayName -ForegroundColor Green
      Set-AzureADApplicationProxyApplicationCustomDomainCertificate -ObjectId $CustomDomainApp.ObjectID -PfxFilePath "$PFXLocation" -Password $PFXPassword
    }

}

else {
  Write-Host 'Apps not approved for change' -ForegroundColor Red
  
}