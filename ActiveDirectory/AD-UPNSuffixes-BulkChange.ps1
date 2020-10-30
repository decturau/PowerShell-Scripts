<#

.Synopsis
Active Directory UPN Management

.Description
This script can add and modify UPN suffixes. Useful when preparing for AAD Connect. 

.Notes
Author:     Declan Turley   
Version:    1.0
Notes:      Run on a DC or server with RSAT. 

#>

# This will create the function "Menu" which will allow user see an interactive menu.
Function Menu 
{
    #clear the screen
    Clear-Host        
    Do
    {
        Clear-Host 
        
        #Title and options for the menu                                                                      
        Write-Host -Object 'Identify, Modify and Add UPN Suffixes for Doamin and Users ' -ForegroundColor Yellow
        Write-Host -Object ''
        Write-Host -Object '1.  Check your current UPN suffixes '
        Write-Host -Object ''
        Write-Host -Object '2.  Add a new UPN suffix'
        Write-Host -Object ''
        Write-Host -Object '3.  Change UPN for an OU (Includes sub OU,s. Can be used for whole directory)'
        Write-Host -Object ''
        Write-Host -Object '4.  Change all users from old suffix to new'
        Write-Host -Object ''
        Write-Host -Object '5.  Search a UPN suffix for users'
        Write-Host -Object ''
        Write-Host -Object 'Q.  Quit'
        Write-Host -Object $errout
        $Menu = Read-Host -Prompt '(Select 0-5 or Q to Quit)'
 
        switch ($Menu) 
        {
           1 
            {
                #This command will get your current UPN suffixes
                Clear-Host

                #Get AD Forest name and set variable
                $Forest=Get-ADForest | select-object -ExpandProperty Name

                Write-Host -Object 'Current UPN suffixes (Note: This may note include your domain.local)' -ForegroundColor Yellow
                Write-Host -Object ''
                Get-ADforest $Forest | select -ExpandProperty UPNSuffixes | Out-Host
                pause
            }
            2 
            {
                
                #This command will prompt the user for the Domain foret
                Clear-host
                Write-Host -Object 'Add a UPN Suffix to your Forest ' -ForegroundColor Yellow
                Write-Host -Object ''

                #Get AD Forest name and set variable
                $Forest1=Get-ADForest | select -ExpandProperty Name
                
                #Get the new suffix from the user
                $NewSuffix=Read-Host 'Enter a new UPN suffix for your forst (E.g. domain.com)'

                #Set the new suffix on the forest
                Set-ADForest $Forest1 -UPNSuffixes @{add=$NewSuffix}

                # success message
                Write-Host -Object ''
                Write-Host 'Suffix' $NewSuffix 'added. Press enter to return to the menu.' -ForegroundColor Green
                pause
            }
            3 
            {
             
               Clear-Host
               Write-Host -Object 'Update Users in an OU (As well as every Sub-OU. New UPN will be samAccountName@new.suffix)' -ForegroundColor Yellow
               Write-Host -Object ''
               Write-Host -Object 'Distingused name can be found in the Attribute Editor on the OU within ADUC. You will need advanced view to see it.' -ForegroundColor Magenta
               Write-Host -Object 'You can also select the root of your domain for all users. E.g. Set below to DC=domain,DC=local' -ForegroundColor Magenta
               
               

               #Get the user to input the full DN of the OU they wish to change
               $ou=Read-Host 'Enter the full distinguished name of your OU (No Quotes)'

               #Get all users within that specified OU and every sub OU
               $Users=Get-ADUser -SearchBase $OU -Filter * | select -ExpandProperty SamAccountName

               #Get Available Suffixes
               $Forest2=Get-ADForest | select-object -ExpandProperty Name
               $AvailableSuffixes=Get-ADforest $Forest2 | select -ExpandProperty UPNSuffixes
                          
               # Display available suffixes
               Write-Host -Object ''
               Write-Host -Object 'These are your available UPN suffixes.' -ForegroundColor Magenta
               $AvailableSuffixes | Out-Host
               Write-Host -Object ''
                
               #Get user to define the new suffix they wish to apply
               $NewSuffix=Read-Host 'Enter the new UPN suffix you wish to apply to users'
               Write-Host -Object ''

               #Set each user to the new suffix for their user principal name
               ForEach ($user in $users) {
                    $NewUPN=$user + "@" + $NewSuffix
                    % {Write-Host "Changing UPN suffix for" $user "- Please wait."; Set-ADUser $user -UserPrincipalName $NewUPN
          
                    }

               }

               # success message
               Write-Host -Object ''
               Write-Host 'UPN suffixes changed. Press enter to return to the menu.' -ForegroundColor Green
               pause
              
               
            }
            4  
            {
             
               Clear-Host
               Write-Host -Object 'Update every user (with the old suffix) to the new one' -ForegroundColor Yellow
               Write-Host -Object ''

               #Specificy the old suffix
               $oldsuffix=Read-Host 'Enter the old UPN suffix (E.g. Domain.local)'
               Write-Host -Object ''

               #Get Available Suffixes
               $Forest3=Get-ADForest | select-object -ExpandProperty Name
               $AvailableSuffixes=Get-ADforest $Forest3 | select -ExpandProperty UPNSuffixes

               # Display available suffixes
               Write-Host -Object ''
               Write-Host -Object 'These are your available UPN suffixes.' -ForegroundColor Magenta
               $AvailableSuffixes | Out-Host
               Write-Host -Object ''

               #Enter the new suffix
               $newsuffix=Read-Host 'Enter the new UPN siffux (E.g. Domain.com)'
               
               #Create a filter for the local user search
               $oldfilter="*" + $oldsuffix

               #Search AD for all users with UPN containing the old suffix
               $LocalUsers = Get-ADUser -Filter {UserPrincipalName -like $oldfilter} -Properties userPrincipalName -ResultSetSize $null

               #For each user found, update with the new suffix
               $LocalUsers | foreach {$newUpn = $_.UserPrincipalName.Replace($oldsuffix,$newsuffix); $_ | Set-ADUser -UserPrincipalName $newUpn | Out-Host}

               # success message
               Write-Host -Object ''
               Write-Host 'UPN suffixes changed. Press enter to return to the menu.' -ForegroundColor Green
               pause
                            
            }
            5
            {

              Clear-Host
              Write-Host -Object 'Check a UPN Suffix and view associated users' -ForegroundColor Yellow
              Write-Host -Object ''

              #Get siffix to search
              $Suffix=Read-Host 'Enter the suffix you want to search'
              
              #Add search criteria as variable (-Like *suffix)
              $suffixfilter="*" + $suffix

              #Search the users meeting criteria
              $users=Get-ADUser -Filter {UserPrincipalName -like $suffixfilter} | Select UserPrincipalName,samAccountName
              Write-Host -Object ''
              Write-Host 'Users in the following UPN suffix:' $Suffix -ForegroundColor Magenta
              Write-Host -Object ''
              $users | Out-Host
              Write-Host -Object ''
              
              # success message
              Write-Host 'Complete. Press enter to return to menu.' -ForegroundColor Green
              pause
                      
            }
            
            Q 
            {
                Exit
            }   
            default
            {
                $errout = 'Invalid Option - Please select betwee 1-5 or Q to Quit'
            }
 
        }
    }
    until ($Menu -eq 'q')
}   

# Launch The Menu
Menu
