# Script Created by Declan T. 
# This script is written to identify Network Adapter Events 

# We will be using the network adapter servicename as as the "Source" of the event logs. As there is more than one, we store them as a variable which will be called at the final stage. 
$NetworkServices=Get-wmiobject win32_networkadapter | Select-Object -ExpandProperty ServiceName 

#Clear the screen for presentation
Clear-Host

#Title
Write-Host -Object '***************************************************************'
Write-Host -Object '  How far back do you want to log Network Adapter Events for?' -ForegroundColor Yellow
Write-Host -Object '***************************************************************'

# User must state how many hours to retrieve logs for. This variable will be called in the final stage.
$Hours=Read-Host 'Please enter the number of hours you want to check logs for'

#Clear screen and present title
clear-host
Write-Host -Object '*********************'
Write-Host -Object '  Finding your logs' -ForegroundColor Yellow
Write-Host -Object '*********************'

#Pull the hours and source variables and find relevant logs and get event logs. 
% {Write-Host "Looking for Network Adapter Events"; Get-EventLog -LogName System -After (Get-Date).AddHours(-$hours) -Source $NetworkServices} |  select Source,TimeGenerated,Username,Message | Format-List
