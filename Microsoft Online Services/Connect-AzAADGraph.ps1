<#
.Synopsis
Connect to MS Graph, Az, and AzureAD
.Description
Connect to the mentioned services using a service principal. 
.Link 
https://dectur.com/service-principal/
.Notes
Author:     Declan Turley   
Version:    1.0
Notes:      Service principal must be setup with appropiate permissions. 
#>

#Set Variables
$AppId              = ''
$CertThumbprint     = ''
$KeyVaultName       = '' 
$KeyVaultSecret     = ''
$MsTenant           = ''
$AuthUrl            = "https://login.microsoftonline.com/$MsTenant"

#Connect to Microsoft Azure (Az) 
Connect-AzAccount -ApplicationId $AppId -CertificateThumbprint $CertThumbprint -Tenant $MsTenant -ServicePrincipal

#Connect to Exchange Online
Connect-ExchangeOnline -AppId $AppId -CertificateThumbprint $CertThumbprint -Organization $MsTenant

#Connect to Azure AD
Connect-AzureAD -ApplicationId $AppId -CertificateThumbprint $CertThumbprint -TenantDomain $MsTenant

#Get the client secret from vault
$newSecret      = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecret).SecretValueText

#Update the MS Graph environment, then connect using the client secret
Update-MSGraphEnvironment -AppId $appID -AuthUrl $AuthUrl
Connect-MSGraph -ClientSecret $newSecret
