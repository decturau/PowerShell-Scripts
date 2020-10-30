<#
.Synopsis
Generate Immutable ID from an M365 User Export
.Description
This script will take an export of M365 users and match them to their on-prem identity. It will get the ObjectGUID and convert it to the ImmutableID.
This is known as a hard match when deploying Azure Active Directory Connect. 
.PARAMETER CSVPath
The path to the CSV you are importing with the UPN field. E.g. C:\temp\M365Export.csv
.PARAMETER CSVExportPath
The path to export the new csv to. For example C:\temp\ImmIDEXportAD.csv
.Notes
You must select all users in M365 and export them to CSV. Change the 'user principal name' heading to 'UPN'. Users must exist in AD already with the same UPN. 
#>

Param(
    [Parameter(Mandatory = $true)]
    [string] $CSVPath,
    [Parameter(Mandatory=$True)]
    [String] $CSVExportPath
)

$csv = Import-Csv "$CSVPath"
foreach ($l in $csv){
    $user = (Get-ADUser -Filter "UserPrincipalName -eq '$($l."UPN")'")
    $ImmutableID = [system.convert]::ToBase64String(([GUID]$user.objectGUID).ToByteArray())
    $Table = [PSCustomObject]@{
        'Name'          = $user.Name
        'UPN'           = $user.UserPrincipalName
        'ObjectGUID'    = $user.ObjectGUID
        'ImmutableID'   = $ImmutableID   
    }
        $Table | Export-Csv -Path "$CSVExportPath" -NoTypeInformation -Append
}
