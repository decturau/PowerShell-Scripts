# This script was created by Declan T.
# This script intends connect to your partner portal and retrieve essential data like licensing, partner relationships and Global Admins with the option to export. 

#Connect to MSOL  
Connect-MsolService

#Get all Partner Relationships
$Global:Partners = Get-MsolPartnerContract -All
$Global:CountPartners = $Global:Partners | measure | select -ExpandProperty count 

Clear-Host

#Create Menu function 
Function Menu 

{    
    Do
    {
        

        Clear-Host
        
        # Menu Options                                                                       
        Write-Host -Object 'Office 365 Partner Management' -ForegroundColor Yellow
        Write-Host -Object ''
        Write-Host -Object '1.  Display Partner Relationships'
        Write-Host -Object ''
        Write-Host -Object '2.  Display All Partners Licenses (Less than 1000 Active Units)'
        Write-Host -Object ''
        Write-Host -Object '3.  List all Global Admins for Each Partner'
        Write-Host -Object ''
        Write-Host -Object '4.  Export all Licenses as CSV'
        Write-Host -Object ''
        Write-Host -Object '5.  Export all Global Administrators as CSV'
        Write-Host -Object ''
        Write-Host -Object 'Q.  Quit'
        Write-Host -Object $errout
        $Menu = Read-Host -Prompt '(Select 1-5 or Q to Quit)'

        # Menu Switches
        switch ($Menu) 
        {
           1 
            {
                    Clear-Host  
                        Write-Host 'Gathering Partner Information' -ForegroundColor Yellow   
                        
                        # Get Partner names and phone number
                        foreach ($partner in $Global:Partners)
                                {Get-MsolCompanyInformation -TenantId $partner.TenantId | select DisplayName,TelephoneNumber}

                        # Display a total count of partners
                        Write-Host 'Current count of Partner Relationships is' $Global:CountPartners -ForegroundColor Yellow 
                        Pause
            }

            2 
            {                
                Clear-Host
                foreach ($Partner in $Global:Partners) { 
                    Write-Host 'Current Licenses for' $Partner.Name -ForegroundColor Yellow
                    # Get all licenses less than 1000 to exclude free ones
                    Get-MsolAccountSku -TenantId $Partner.TenantID  | Where-Object {$_.ActiveUnits -le 1000} | select SkuPartNumber,ActiveUnits,ConsumedUnits | Format-Table } 
                    Pause
            }

            3 
            {
             
                Clear-Host
                Write-Host 'Getting Global Admin information' -ForegroundColor Yellow
                
                # Get all Global admins for each client
                $AllGlobalAdmins = foreach ($Partner in $Global:Partners) {
                $GlobalAdmins = Get-MsolRoleMember -TenantId $Partner.TenantId -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId 
                # Get company information 
                $Company = (Get-MsolCompanyInformation -TenantId $Partner.TenantID)
                                
                        foreach ($admin in $GlobalAdmins) {
 
                            [pscustomobject]@{
                                DisplayName  = $admin.DisplayName
                                EmailAddress = $admin.EmailAddress
                                MFAStatus = $admin.StrongAuthenticationRequirements.State
                                CompanyName  = $Company.DisplayName
            
                            }
                        }
                    } 
            
                    $AllGlobalAdmins | Format-Table    
                    pause      
            }

            4 
            {                
                Clear-Host
                # Export path
                $LicenseExportPath=Read-Host 'Enter path to export CSV. I.e. C:\temp\CSPLicenses'

                $Licneses= foreach ($Partner in $Global:Partners) {Get-MsolAccountSku -TenantId $Partner.TenantId  | Where-Object {$_.ActiveUnits -le 1000} | Select-Object AccountName,SkuPartNumber,ActiveUnits,ConsumedUnits } 
                $Licneses | Export-Csv -Path $LicenseExportPath
                Write-Host 'Licenses exported to' $LicenseExportPath -ForegroundColor Green
                Pause
            }

            5 
            {                
                Clear-Host
                $GlobalAdminsExportPath=Read-Host 'Enter path to export CSV. I.e. C:\temp\CSPGlobalAdmins.csv'
                $GlobalAdminsCount= $AllGlobalAdmins | measure | select -ExpandProperty count
                # Pull variable from option 3 and export
                $AllGlobalAdmins | Export-Csv -Path $GlobalAdminsExportPath
                Write-Host $GlobalAdminsCount 'Global Admins out of' $Global:CountPartners 'partners exported to' $GlobalAdminsExportPath -ForegroundColor Green
                
              
                Pause
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

# Call the Menu Function
Menu
