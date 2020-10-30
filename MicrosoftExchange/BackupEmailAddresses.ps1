<#
.SYNOPSIS
  Expand the EmailAddresses field alongside the Alias of the user. Make it easy to bulk add any deleted address back by parsing the csv. 
.DESCRIPTION
  The script will cycle through all mailboxes and expand each users' email address. Each address will be placed on its own line within a
  CSV file. This file will be in the format Name,Alias,EmailAddress. If a user has 3 email addresses, they will be represeneted on 3 lines.    
.PARAMETER csvPath
  This parameter is the path where the csv will be saved. This path should not inlcude a file name or trailing backslack.  
.NOTES
  Author:         Declan Turley (dectur.com)
    
.EXAMPLE
  BackupEmailAddresses.ps1 -csvPath C:\temp
#>

#Parameter to specify CSV Output
param(
    [Parameter(Mandatory = $true)]
    [string] $csvPath
  )

#Message to confirm CSV Path
$Confirm = Read-Host 'Your CSV will be saved as' $csvPath\MailboxAlias.csv '. If this is path looks correct, enter y. If not, enter n'

If ($Confirm -eq 'y'){

    #Get All Mailbox
    $mb = Get-Mailbox -ResultSize Unlimited

        #Cycle through Mailboxes and obtain each EmailAddress
        foreach ($m in $mb){
            $Addresses = (Get-Mailbox $m.Alias) | ForEach{$_.EmailAddresses}
            #$Alias = $m.Alias
                
                #Cycle through each address and format it as a table
                foreach ($a in $Addresses){ 
                    $table = [PSCustomObject]@{
                    'Name' = $m.Name
                    'Alias' = $m.Alias
                    'UPN' = $m.UserPrincipalName
                    'EmailAddress' = $a
                    }
                
                #Export all values as CSV to the path defined
                $Table | Export-Csv -Path $csvPath\MailboxAlias.csv -NoTypeInformation -Append
                }
        }
    }

else {
    Write-Host 'You did not confirm CSV Path. Please enter it in the format C:\temp. Press enter to exit' -ForegroundColor Red
    pause 
    Exit
}
