<#

.Synopsis
Active Directory Report

.Description
Run on a Domain Controller or server with RSAT. This script will download PowerShell Module and create directories on the C: Drive.
Script must be run as administrator to obtian the DHCP Scopes and Accuarate DCDiag Results. This will prompt you via UAC if not in admin session. 

.Link 
ReportHTML PowerShell Module https://www.powershellgallery.com/packages/ReportHTML/1.4.1.2
Invoke-DCDiag Function https://4sysops.com/archives/use-dcdiag-with-powershell-to-check-domain-controller-health/

.Notes
Author:     Declan Turley   
Version:    1.0
Notes:      Admin permissions required. 
Notes:      Inspired by The Lazy Administrator's script. This is customized to pull different information. 

#>

#Run this script as administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Variable for Report Filename and Title
$ReportTitle = "Active Direcory Assessment"

# Create objects for end report
$DomainInfoTable        = New-Object 'System.Collections.Generic.List[System.Object]'
$ReplicationsTable      = New-Object 'System.Collections.Generic.List[System.Object]'
$TrustsTable            = New-Object 'System.Collections.Generic.List[System.Object]'
$SitesTable             = New-Object 'System.Collections.Generic.List[System.Object]'
$UPNSuffixTable         = New-Object 'System.Collections.Generic.List[System.Object]'
$DCDiagFinalTable       = New-Object 'System.Collections.Generic.List[System.Object]'
$DomainFSMOTable        = New-Object 'System.Collections.Generic.List[System.Object]'
$DNSServersTable        = New-Object 'System.Collections.Generic.List[System.Object]'
$DHCPServersTable       = New-Object 'System.Collections.Generic.List[System.Object]'
$DHCPScopesTable        = New-Object 'System.Collections.Generic.List[System.Object]'
$DomainAdminsTable      = New-Object 'System.Collections.Generic.List[System.Object]'
$EnterpriseAdminsTable  = New-Object 'System.Collections.Generic.List[System.Object]'
$SchemaAdminsTable      = New-Object 'System.Collections.Generic.List[System.Object]'
$DomainControllersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$AllServersTable        = New-Object 'System.Collections.Generic.List[System.Object]'

#Declare the variables for the path. This will be used to store modules and report.
$PathLocation = "C:\"
$PathDirectory = "Reports"
$FullPath = $PathLocation + $PathDirectory

#Test the path to see if it exsists
$PathTest1 = Test-Path -Path $FullPath

#If path exists, download module. If not, create and download module. 
IF ($PathTest1 -eq "True")
{
    Write-Host $FullPath 'Already Exists' -ForegroundColor Yellow
    Write-Host 'Downloading Module' -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/package/ReportHTML/1.4.1.2" -OutFile $FullPath\ReportHTML.nupkg
}

Else 
{
    Write-Host 'Path does not exist' -ForegroundColor Yellow
    Write-Host 'Creating Path' -ForegroundColor Yellow
    New-Item -Path $PathLocation -Name $PathDirectory -ItemType Directory 

    #Test new path
    $PathTest2 = Test-Path -Path $FullPath
    IF ($PathTest2 -eq "True")
    {
    Write-Host $FullPath 'now Exists' -ForegroundColor Yellow
    Write-Host 'Downloading Module' -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/package/ReportHTML/1.4.1.2" -OutFile $FullPath\ReportHTML.nupkg
    }

    Else 
    {
    Write-Host 'Path could not be created. Please create manually.' -ForegroundColor Yellow
    Pause
    Exit
    }

}

#Rename the folder to Zip for extraction 
Write-Host 'Renaming the Download to .zip' -ForegroundColor Yellow
Rename-Item $FullPath\ReportHTML.nupkg $FullPath\ReportHTML.zip | Out-Host

#Extract the Module to the same location 
Write-Host 'Extratcing the archive' -ForegroundColor Yellow
$ZipFile = $FullPath + '\ReportHTML.zip'
$ExtractPath = $FullPath + '\Module'
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $ExtractPath)

#Rename the sample files to stop sample logos on report 
Write-Host 'Renaming sample files' -ForegroundColor Yellow
Rename-Item $FullPath\Module\Sample.jpg $FullPath\Module\Old-Sample.jpg
Rename-Item $FullPath\Module\Alternate.jpg $FullPath\Module\Old-Alternate.jpg

#Impport the downloaded module 
Write-Host 'Importing the HTML Module' -ForegroundColor Yellow
Import-Module $FullPath\Module\ReportHTML.psm1

#Get AD Recycle Bin Status
Write-Host 'Gathering Recycle Bin Status' -ForegroundColor Yellow
$ADRecycleBinStatus = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes

if ($ADRecycleBinStatus.Count -lt 1)
{
	
	$ADRecycleBin = "Disabled"
}

else
{
	
	$ADRecycleBin = "Enabled"
}

#Get Domain Information - Variables will be referenced throughout script
Write-Host 'Gathering domain inf' -ForegroundColor Yellow
$ADDomain               = Get-ADDomain
Write-Host 'Gathering forest info' -ForegroundColor Yellow
$ADForest               = Get-ADForest
Write-Host 'Gathering FSMO role holders' -ForegroundColor Yellow
$InfrastructureMaster   = $ADDomain.InfrastructureMaster
$RIDMaster              = $ADDomain.RIDMaster
$PDCEmulator            = $ADDomain.PDCEmulator
$DomainNamingMaster     = $ADForest.DomainNamingMaster
$SchemaMaster           = $ADForest.SchemaMaster
Write-Host 'Gathering schema version' -ForegroundColor Yellow
$SchemaVersion          = (Get-ADObject (get-adrootdse).schemaNamingContext -Property objectVersion).objectVersion
Write-Host 'Gathering functional levels' -ForegroundColor Yellow
$DomainLevel            = $ADDomain.DomainMode
$ForestLevel            = $ADForest.ForestMode
Write-Host 'Gathering UPN suffixes' -ForegroundColor Yellow
$UPNSuffixes            = $ADForest.UPNSuffixes
Write-Host 'Gathering sites' -ForegroundColor Yellow
$DomainSites            = $ADForest.Sites
Write-Host 'Gathering Admin groups info' -ForegroundColor Yellow
$DomainAdmins           = Get-ADGroupMember "Domain Admins"
$EnterpriseAdmins       = Get-ADGroupMember "Enterprise Admins"
$SchemaAdmins           = Get-ADGroupMember "Schema Admins"
Write-Host 'Gathering enabled users' -ForegroundColor Yellow
$EnabledUsers           = (Get-ADUser -Filter * -Properties *).Where({$_.Enabled -eq $True})
Write-Host 'Gathering domain trusts' -ForegroundColor Yellow
$Trusts                 = (Get-ADTrust -Filter * -Properties *)
Write-Host 'Gathering Domain Controllers' -ForegroundColor Yellow
$DomainControllers      = Get-ADDomainController -Filter *
Write-Host 'Gathering Domain Servers' -ForegroundColor Yellow
$DomainServers          = (Get-ADComputer -Filter * -Properties *).Where({$_.OperatingSystem -Like "*server*"})

#Gather and organsie Domain Information
Write-Host 'Compiling Domain Information Table' -ForegroundColor Yellow
$ADTable    = [PSCustomObject]@{
	
	'Domain'			    = $ADDomain.DNSRoot
	'AD Recycle Bin'	    = $ADRecycleBin
	'Schema Version'        = $SchemaVersion
    'Domain Level'          = $DomainLevel
    'Forest Level'          = $ForestLevel
    'No of UPN Suffixes'    = $UPNSuffixes.Count
    'No. of Domain Admins'  = $DomainAdmins.Count
    'No. of Enabled Users'  = $EnabledUsers.Count
    'No. of Sites'          = $DomainSites.Count
    'No. of Trusts'         = (Measure-Object -InputObject ($Trusts)).Count
    'No. of Servers'        = $DomainServers.Count
    'No. DCs'               = $DomainControllers.Count
}

$DomainInfoTable.Add($ADTable)

#Get FSMO Role Holders
Write-Host 'Compiling FSMO Roles Table' -ForegroundColor Yellow
$FSMOTable  = [PSCustomObject]@{

    'Infrastructure Master' = $InfrastructureMaster
	'RID Master'		    = $RIDMaster
	'PDC Emulator'		    = $PDCEmulator
	'Domain Naming Master'  = $DomainNamingMaster
    'Schema Master'		    = $SchemaMaster
}

$DomainFSMOTable.Add($FSMOTable)

#Get Relication Status of DC's
Write-Host 'Gathering & compiling Replication Status' -ForegroundColor Yellow
$Replications = (Get-ADReplicationPartnerMetadata -Target $ADDomain.DNSRoot -Scope Domain)

foreach ($Replication in $Replications) {
        
        #If statement to convert last result code to readable value
        If ($Replication.LastReplicationResult -eq '0')
        {
        $Result = 'Success'
        }
        Else 
        {
        $Result = 'Error'
        }

        $AllReplications  = [PSCustomObject]@{
        'Server'              =  $Replication.Server
        'Partner'             =  ($Replication).Partner -replace "CN=NTDS Settings,CN=|,.*" 
        'Last Success'        =  $Replication.LastReplicationSuccess
        'Last Result'         =  $Result
        'Partner Type'        =  $Replication.PartnerType
    }

    $ReplicationsTable.Add($AllReplications)
}

#If there are no replication servers add a message instead
if (($ReplicationsTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'There are no replication servers.'
	}
	$ReplicationsTable.Add($Message)
}

#Get AD Trusts 
Write-Host 'Compiling Trust Relationships Table' -ForegroundColor Yellow
foreach ($Trust in $Trusts) {
    $AllTrusts  = [PSCustomObject]@{
    'Target Domain'        =  $Trust.Target
    'Direction'            =  $Trust.Direction
    'Created Date'         =  $Trust.Created
    'Deletion Protected'   =  $Trust.ProtectedFromAccidentalDeletion
    }

    $TrustsTable.Add($AllTrusts)
}

#If there are no trusts add a message instead
if (($TrustsTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'There are no trusts.'
	}
	$TrustsTable.Add($Message)
}

#Function for DCDiag parsing 
function Invoke-DcDiag 
{
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController
    )
 
    $result = dcdiag /s:$DomainController
    $result | select-string -pattern '\. (.*) \b(passed|failed)\b test (.*)' | foreach {
        $Output = @{
            TestName = $_.Matches.Groups[3].Value
            TestResult = $_.Matches.Groups[2].Value
            Entity = $_.Matches.Groups[1].Value
        }
        [pscustomobject]$Output
    }
}

#Gather DCDiag Test Results
Write-Host 'Gathering abd compiling DC Diagnostics' -ForegroundColor Yellow
foreach ($DomainController in $DomainControllers)
{
    $DCDiagTests = Invoke-DcDiag -DomainController $DomainController
    $DCDiagFailed = $DCDiagTests.Where({$_.TestResult -eq "Failed"})

    foreach ($FailedTest in $DCDiagFailed)
    {
        $DCDiagTable = [PSCustomObject]@{
            'Server/Object' =  $FailedTest.Entity
            'Test Name'     =   $FailedTest.TestName
            'Test Result'   =   $FailedTest.TestResult
        }
        $DCDiagFinalTable.Add($DCDiagTable)
    }

}

#Display message if no failed tests
if (($DCDiagFinalTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'No failures found.'
	}
	$DCDiagFinalTable.Add($Message)
}

#Get AD Sites 
foreach ($Site in $DomainSites)
{
    $AllSites  = [PSCustomObject]@{
        'Site Name' =  $Site
    }
    $SitesTable.Add($AllSites)
}

#Display message if no failed tests
if (($SitesTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'No sites found.'
	}
	$SitesTable.Add($Message)
}

#Get UPN Suffixes 
Write-Host 'Compiling UPN Suffixes Table' -ForegroundColor Yellow
foreach ($UPNSuffix in $UPNSuffixes)
{
    $AllUPNs  = [PSCustomObject]@{
        'UPN Suffix' =  $UPNSuffix
    }
    $UPNSuffixTable.Add($AllUPNs)
}

#Message if no UPN in domain
if (($UPNSuffixTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'No UPNs to report.'
	}
	$UPNSuffixTable.Add($Message)
}

#Gather DNS Server settings 
Write-Host 'Gathering and compiling DNS Name Servers' -ForegroundColor Yellow
#$DNSRoot            = $ADDomain.DNSRoot
$NameServers        = (Resolve-DnsName -Type NS -Name $ADDomain.DNSRoot).Where({$_.Type -eq "NS"})

foreach ($Nameserver in $NameServers)
{
    $AllDNSServers  = [PSCustomObject]@{
        'Name'           =  $Nameserver.Name
        'DNS Type'       =  $Nameserver.Type
        'Server'         =  $Nameserver.Namehost
    }

    $DNSServersTable.Add($AllDNSServers) 

}

#Display message if no info
if (($DNSServersTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'No info found.'
	}
	$DNSServersTable.Add($Message)
}

#Gather DHCP Servers for Domain
Write-Host 'Gathering Authorized DHCP Servers' -ForegroundColor Yellow
$DHCPServers = Get-DhcpServerInDC
foreach ($DHCPserver in $DHCPServers)
{
    $DHCPTable      = [PSCustomObject]@{
        'Name'          = $DHCPserver.DNSName
        'IP Address'    = $DHCPserver.IPAddress.IPAddressToString 
    }

    $DHCPServersTable.Add($DHCPTable)
}

#Message if no DHCP servers in Domain
if (($DHCPServersTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'Could not locate any DHCP Servers in DC.'
	}
	$DHCPServersTable.Add($Message)
}

#Gather DHCP Scopes for Servers (If Possible)
Write-Host 'Gathering DHCP Scopes If Possible' -ForegroundColor Yellow
foreach ($DHCPServer in $DHCPservers)
{
    $scopes = Get-DhcpServerv4Scope -ComputerName $DHCPserver.DNSName -ErrorAction SilentlyContinue
        foreach ($scope in $scopes){
            $DHCPScopes     = [PSCustomObject]@{
                'Server'        = $DHCPserver.DNSName  
                'Scope Name'    = $scope.Name
                'Subnet'        = $Scope.SubnetMask
                'Start IP'      = $scope.StartRange
                'End IP'        = $scope.EndRange
                'Lease Time'    = $scope.LeaseDuration
                'State'         = $Scope.State
                'Ping Success'  = [bool](Test-Connection -ComputerName $DHCPserver.DNSName -ErrorAction SilentlyContinue)
        }

        $DHCPScopesTable.Add($DHCPScopes)        

    } 
}

#Message if no DHCP servers in domain
if (($DHCPScopesTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'Could not locate any Server DHCP Scopes.'
	}
	$DHCPScopesTable.Add($Message)
}

#Gather Domain Controller information
Write-Host 'Gathering Domain Controllers' -ForegroundColor Yellow

foreach ($DomainController in $DomainControllers)
{
    $AllDomainControllers    =   [PSCustomObject]@{
        'Name'               =  $DomainController.Name
        'Operating System'   =  $DomainController.OperatingSystem
        'Site'               =  $DomainController.Site
        'IP Address'         =  $DomainController.IPv4Address
        'Global Catalog'     =  $DomainController.IsGlobalCatalog
        'Read Only'          =  $DomainController.IsReadOnly
    }

    $DomainControllersTable.Add($AllDomainControllers)
}

#Gather Servers in AD
Write-Host 'Gathering Domain Servers Information' -ForegroundColor Yellow

foreach ($Server in $DomainServers)
{
    $AllServers     =   [PSCustomObject]@{
        'Name'               =  $Server.Name
        'Operating System'   =  $Server.OperatingSystem
        'Service Pack'       =  $Server.OperatingSystemServicePack
        'IP Address'         =  $Server.IPv4Address
    }
   
    $AllServersTable.Add($AllServers)
}

#Display message if no info
if (($AllServersTable).Count -eq 0)
{
	$Message = [PSCustomObject]@{
		
		Information = 'No info found.'
	}
	$AllServersTable.Add($Message)
}


#Gather and organsie Domian admins
Write-Host 'Gathering Domain Admin Information' -ForegroundColor Yellow
foreach ($DomainAdmin in $DomainAdmins)
{
    $User = Get-ADUser $DomainAdmin -Properties *
  	
	$AllDomainAdmins = [PSCustomObject]@{
		'Name'          = $User.Name
		'Enabled'       = $user.Enabled
        'Last Logon'    = $user.LastLogonDate
	}
	
	$DomainAdminsTable.Add($AllDomainAdmins)
}

#Gather and organsie Enterpise admins
Write-Host 'Gathering Enterprise Admin Information' -ForegroundColor Yellow
foreach ($EnterpriseAdmin in $EnterpriseAdmins)
{
    $User = Get-ADUser $EnterpriseAdmin -Properties *
  	
	$AllEnterpriseAdmins = [PSCustomObject]@{
		'Name'          = $User.Name
		'Enabled'       = $user.Enabled
        'Last Logon'    = $user.LastLogonDate
	}
	
	$EnterpriseAdminsTable.Add($AllEnterpriseAdmins)
}

#Gather and organsie Schema admins
Write-Host 'Gathering Schema Admin Information' -ForegroundColor Yellow
foreach ($SchemaAdmin in $SchemaAdmins)
{
    $User = Get-ADUser $SchemaAdmin -Properties *
  	
	$AllSchemaAdmins = [PSCustomObject]@{
		'Name'          = $User.Name
		'Enabled'       = $user.Enabled
        'Last Logon'    = $user.LastLogonDate
	}
	
	$SchemaAdminsTable.Add($AllSchemaAdmins)
}

#Tabs for Report
$tabarray = @('Active Directory')

#Fill in Final Report for Export
Write-Host 'Generating Report' -ForegroundColor Yellow

$ADFinalReport = New-Object 'System.Collections.Generic.List[System.Object]'
$ADFinalReport.Add($(Get-HTMLOpenPage -TitleText $ReportTitle))
$ADFinalReport.Add($(Get-HTMLTabHeader -TabNames $tabarray))
$ADFinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[0] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Domain Information: Overview"))
$ADFinalReport.Add($(Get-HTMLContentTable $DomainInfoTable))
$ADFinalReport.Add($(Get-HTMLContentClose))

$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Domain Health Checks"))
$ADFinalReport.Add($(Get-HTMLColumn1of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Replication Status"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $ReplicationsTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumn2of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Failed DCDiag Tests"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DCDiagFinalTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLContentClose))

#Custom variable to include count in header
$DomainSiteHeader = [string]($DomainSites).Count + ' Active Directory Sites'
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Sites, Relationships & UPN's"))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 1 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText $DomainSiteHeader))
$ADFinalReport.Add($(Get-HTMLContentDataTable $SitesTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 2 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Trust Relationships"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $TrustsTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 3 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "UPN Suffixes"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $UPNSuffixTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLContentclose))

$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Domain Controllers"))
$ADFinalReport.Add($(Get-HTMLColumn1of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "FSMO Role Holders"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DomainFSMOTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumn2of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "All Domain Controllers"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DomainControllersTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLContentClose))

$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "DNS & DHCP Servers"))
$ADFinalReport.Add($(Get-HTMLColumn1of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "DNS Servers"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DNSServersTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumn2of2))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "DHCP Servers"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DHCPServersTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLContentClose))

$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "DHCP Scopes"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DHCPScopesTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))

#Custom variable to include count in header
$AllServersHeader = [string]($DomainServers).Count + ' Domain Servers'
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText $AllServersHeader))
$ADFinalReport.Add($(Get-HTMLContentDataTable $AllServersTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))

$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Administrator Groups"))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 1 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Domain Administrators"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $DomainAdminsTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 2 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Schema Administrators"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $SchemaAdminsTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLColumnOpen -ColumnNumber 3 -ColumnCount 3))
$ADFinalReport.Add($(Get-HTMLContentOpen -HeaderText "Enterprise Administrators"))
$ADFinalReport.Add($(Get-HTMLContentDataTable $EnterpriseAdminsTable -HideFooter))
$ADFinalReport.Add($(Get-HTMLContentClose))
$ADFinalReport.Add($(Get-HTMLColumnClose))
$ADFinalReport.Add($(Get-HTMLContentclose))

#Save the report
Save-HTMLReport -ReportContent $ADFinalReport -ShowReport -ReportName $ReportTitle -ReportPath $FullPath
