<#
.Synopsis
Get basic information of your PC. 

.Description
Get make, model, processor, domain, BIOS, NIC and other info. 

.Notes
Author:     Declan Turley   
Version:    1.0

#>

#This will create the function "Menu" which will allow user see an interactive menu.
Function Menu 
{
    #clear the screen
    Clear-Host        
    Do
    {
        Clear-Host 
        
        #Title and options for the menu                                                                      
        Write-Host -Object '   Get Your Computer Info'
        Write-Host -Object '   **********************'
        Write-Host -Object '      Select an Option ' -ForegroundColor Yellow
        Write-Host -Object '   **********************'
        Write-Host -Object '1.  Get Make, Model and Domain Information '
        Write-Host -Object ''
        Write-Host -Object '2.  Check your BIOS Information'
        Write-Host -Object ''
        Write-Host -Object '3.  Check your Motherboard Information'
        Write-Host -Object ''
        Write-Host -Object '4.  Check your Processor Information'
        Write-Host -Object ''
        Write-Host -Object '5.  Check Network Adapter Configurations'
        Write-Host -Object ''
        Write-Host -Object 'Q.  Quit'
        Write-Host -Object $errout
        $Menu = Read-Host -Prompt '(Select 0-5 or Q to Quit)'
 
        switch ($Menu) 
        {
           1 
            {
                #This command will get the make model and other information about the PC
                Clear-Host
        Write-Host -Object '   **********************'
        Write-Host -Object '    Make, Model & Domain ' -ForegroundColor Yellow
        Write-Host -Object '   **********************'
                Get-WMIObject -Class Win32_ComputerSystem
                pause
            }
            2 
            {
                
                #This command will grab the BIOS information such as version and serial number
                Clear-host
                Write-Host -Object '   **********************'
                Write-Host -Object '       BIOS Information ' -ForegroundColor Yellow
                Write-Host -Object '   **********************'
                Get-WMIObject -Class Win32_BIOS 
                pause
            }
            3 
            {
               Clear-Host
                Write-Host -Object '  *************************'
                Write-Host -Object '   Motherboard Information ' -ForegroundColor Yellow
                Write-Host -Object '  *************************'
               Get-WMIObject -Class Win32_Baseboard 
               pause

            }
            4 
            {
                #This will grab the processor info
               Clear-Host
               Write-Host -Object '   *****************'
               Write-Host -Object '    CPU Information ' -ForegroundColor Yellow
               Write-Host -Object '   *****************'
               Get-WMIObject -Class Win32_Processor 
               pause
               
            }
             5 
            {
                #This will grab the network adapter configuration info
               Clear-Host
               Write-Host -Object '  *************************************'
               Write-Host -Object '  Netwrok Adapter Config Information ' -ForegroundColor Yellow
               Write-Host -Object ' **************************************'
               Get-WMIObject -Class Win32_NetworkAdapterConfiguration | Select Description,IPAddress,DefaultIPGateway | Format-Table
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
