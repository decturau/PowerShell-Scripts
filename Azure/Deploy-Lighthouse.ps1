<#
.SYNOPSIS
  This script will onboard the customer's selected subscription to Azure Lighthouse. 

.DESCRIPTION
  Customer, with owner rights on the subscription, must run this script. They will be required to select a tenant and subscription to delegate.    

.NOTES
  Version:        1.0
  Author:         Declan Turley
  Purpose:        Easy customer onboarding.  

.Link 
Delegate example JSON
https://github.com/Azure/Azure-Lighthouse-samples/blob/master/templates/delegated-resource-management/delegatedResourceManagement.json
 
.Link
Params example JSON
https://github.com/Azure/Azure-Lighthouse-samples/blob/master/templates/delegated-resource-management/delegatedResourceManagement.parameters.json

.EXAMPLE
  .\Deploy-Lighthouse.ps1 -Name "MSP Offer" -DelegateJSONPath "C:\temp\delegate.json" -ParamJSONPath "C:\temp\params.json" -Location "Canada Central"
#>

Param(
    [Parameter(Mandatory = $true)]
    [string] $DelegateJSONPath,
    [Parameter(Mandatory=$True)]
    [String] $ParamJSONPath,
    [Parameter(Mandatory=$True)]
    [String] $Name,
    [Parameter(Mandatory=$True)]
    [String] $Location
)

#Check if Az module is installed
Write-Host 'Checking if Az module is installed' -ForegroundColor Yellow
$check = [bool](Get-InstalledModule -name Az -ErrorAction SilentlyContinue)

If ($check -eq 'True'){
    Write-Host 'Az Module installed' -ForegroundColor Green
}
else {
    Write-Host 'Az Module not installed' -ForegroundColor Red
    $StartInstall = Read-Host 'Would you like to install it now?'  
    $StartInstall

    If ($StartInstall -eq 'Y'){
        Write-Host ' Installing Az Module' -ForegroundColor Yellow
        Install-Module -Name Az -AllowClobber -Force
    }
    else {
        Write-Host 'Declined to install. Please run the script again when module is available.' -ForegroundColor Red
        Pause
        Exit
    }
} 

Write-Host 'Please Connect to the customer tenant with owner rights' -ForegroundColor Yellow
Connect-AzAccount -Verbose
Get-AzContext

Write-Host 'Getting available Azure AD Tenants' -ForegroundColor Yellow
$tenants = Get-AzTenant -Verbose 

#Lay out tenant per domain
foreach ($t in $tenants){
  
  Write-Host 'Below is the tenant for the following domains' $t.Domains -ForegroundColor Yellow
  Write-Host '-------------------------------------------------------------------------------------------' -ForegroundColor Cyan
  $t | FL
}
Write-Host '-------------------------------------------------------------------------------------------' -ForegroundColor Cyan
 
#Set the tenant ID
$TenantID = Read-Host 'Enter your desired TenantID from above'

#Output selected Tenant ID
Write-Host 'You have selected the following tenant' -ForegroundColor Yellow
Get-AzTenant -TenantId "$TenantID" -Verbose | FL

#Confirm tenant ID
$ConfirmTenant = Read-Host 'Is this correct? (Y/N)'

#Validate confirmation
If ($ConfirmTenant -eq 'Y'){
  Write-Host 'Tenant confrimed' -ForegroundColor Green
}
else {
  Write-Host 'Tenant not confirmed. Please re-run script.' -ForegroundColor Red
  Pause
  Exit
}

#Get subscriptions related to that tenant ID
Write-Host 'Getting available subscriptions for' (Get-AzTenant -TenantId $TenantID).Name -ForegroundColor Yellow
Get-AzSubscription -TenantId $TenantID -Verbose | FT

#Set the Subscription ID
$SubID = Read-Host 'Enter the Id for your subscription'

#Output selected subscription ID
Write-Host 'You selected the following subscription' -ForegroundColor Yellow
Get-AzSubscription -SubscriptionId $SubID -Verbose | FT

#Confirm subscription
$ConfirmSubscription = Read-Host 'Is this correct? (Y/N)'

If ($ConfirmSubscription -eq 'Y'){
  Write-Host 'Subscription confrimed' -ForegroundColor Green
}
else {
  Write-Host 'Subscription not confirmed. Please re-run script.' -ForegroundColor Red
  Pause
  Exit
}

#Set the subscription
Write-Host 'Setting subscription' -ForegroundColor Yellow
Select-AzSubscription $SubID

#Deploy the solution 
Write-Host 'Deploying solution' -ForegroundColor Yellow
$Deployment = New-AzDeployment -Name "$Name" -Location "$Location" -TemplateFile "$DelegateJSONPath" -TemplateParameterFile "$ParamJSONPath" -Verbose 

#Validate successful deployment
IF ($deployment.ProvisioningState -eq 'Succeeded'){
  Write-Host 'Deployment successful' -ForegroundColor Green
}
If ($deployment.ProvisioningState -eq 'Failed'){
  Write-Host 'Deployment failed. Please review errors.' -ForegroundColor Red
}
