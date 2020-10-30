<#
.SYNOPSIS
  Remove unwanted Email Addresses with a specific domain from Exchange users. 
.DESCRIPTION
  The script will cycle through all mailboxes identifying those which have email addresses from a domain you have specified for removal. 
  Each email address with that specified domain will be removed from the users EmailAddresses field.    
.PARAMETER BadDomain
  This parameter is where you specify the domain you wish to remove all associated email addresses.  
.NOTES
  Author:         Declan Turley (dectur.com)
    
.EXAMPLE
  RemoveExchangeDomain.ps1 -BadDomain ad.domain.com 
#>

#Get the 'Bad' Domain
param(
    [Parameter(Mandatory = $true)]
    [string] $BadDomain
  )

#Get all users who have an email address with that domain
$BadUsers = (Get-Mailbox).Where{$_.EmailAddresses -like "*$BadDomain*"}

    #Cycle through the users and get only the email addresses that include that domain
    foreach ($m in $BadUsers){
        $BadAddresses = (Get-Mailbox $m.Alias) | ForEach{$_.EmailAddresses -like "*$BadDomain*"}
            
            #Cycle through each email address with said domain and remove it. 
            foreach($bad in $BadAddresses){
                Write-Host 'Removing' $bad 'from' $m.Alias -ForegroundColor Yellow
                Set-Mailbox $m.Alias -EmailAddresses @{remove=$bad}
            }
    }
