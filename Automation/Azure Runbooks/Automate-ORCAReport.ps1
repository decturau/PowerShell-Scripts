<#

.SYNOPSIS
Automate ORCA reports using Azure Automation. Email content using Keyvault and SendGrid.

.DESCRIPTION
This runbook will connect to your M365 tenant using defined credentials. It will run the 
Office 365 ATP Recommended Configuration Analyzer (ORCA) to assess the posture of Exchnage 
Online Protection and ATP by Canmurray (https://github.com/cammurray/orca). This runbook will
then connect to Aure Key Vault to obtain the SendGrid API key and email your intended recipient 
the report.  

Prerequisite:   Azure Automation account
                Azure Run As account credential
                Exchange Online credentials in Automation account
                SendGrid Account
                Key vault with SendGrid API key stored there - named 'SendGridAPIKey'
                Account with at least View-Only Organization Management for Exchange Online
                ORCA, ExchangeOnlineManagement, Az.Accounts, Az.Profile, Az.Keyvault modeules imported

.PARAMETER AutoExchnageCreds
Automation Credentials for Exchnage Online.

.PARAMETER destEmailAddress
Recipient email address.

.PARAMETER fromEmailAddress
Sender email address.

.PARAMETER Subject
Email subject. 

.PARAMETER VaultName
Key vault name which contains SendGrip API Key

.LINK
https://github.com/decturau/Automation/blob/master/Azure/AutomateORCA/SendGripReport.ps1
#>
Param(
    [Parameter(Mandatory = $true)]
    [string] $AutoExchnageCreds,
    [Parameter(Mandatory=$True)]
    [String] $destEmailAddress,
    [Parameter(Mandatory=$True)]
    [String] $fromEmailAddress,
    [Parameter(Mandatory=$True)]
    [String] $subject,
    [Parameter(Mandatory=$True)]
    [String] $VaultName
)

#Get credentials and connect to Exchnage 
$M365Creds = Get-AutomationPSCredential -Name $AutoExchnageCreds -Verbose
Connect-ExchangeOnline -Credential $M365Creds

#Run the ORCA report
Invoke-ORCA -Output HTML -OutputOptions @{HTML=@{DisplayReport=$False}}

#Get HTML content for input to email
$Path = $($env:LOCALAPPDATA) + '\Microsoft\ORCA\'
$File =  Get-ChildItem -Path $Path | Sort LastWriteTime | select -last 1
$HtmlContent = Get-Content $Path\$File
$CustomBody = Out-String -InputObject $HtmlContent

#Connect to Azure Key Vault and get SendGrid API
$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint | Out-Null
$SENDGRID_API_KEY = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "SendGridAPIKey").SecretValueText
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $SENDGRID_API_KEY)
$headers.Add("Content-Type", "application/json")

#Generate content for email
$body = @{
personalizations = @(
    @{
        to = @(
                @{
                    email = $destEmailAddress
                }
        )
    }
)
from = @{
    email = $fromEmailAddress
}
subject = $subject
content = @(
    @{
        type = "text/html"
        value = $custombody
    }
)
}

$bodyJson = $body | ConvertTo-Json -Depth 4

$response = Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson
