<#
.SYNOPSIS
Microsoft Teams - Export all assigned phonenumbers to CSV or console

.Description
This script will create an overview of all assigned phonenumbers in your Microsoft365 tenant and will export this to CSV or console.

UPDATES:
1.0     > initial setup of the script.

.NOTES
  Version      	   		: 1.0
  Author(s)    			: Erwin Bierens
  Email/Blog/Twitter	: erwin@bierens.it https://erwinbierens.com @erwinbierens

.EXAMPLE
.\Export-TeamsAssignedNumbers.ps1

#>
#Requires -Version 3.0

Write-Host -ForegroundColor Cyan "[OK] Loading Script"

# you can change the output of the script to console or csv. 
$OutputType = "CSV" #OPTIONS: CSV - Outputs CSV to specified FilePath, CONSOLE - Outputs to console

# do not change anything below

$FileName = "TeamsAssignedNumbers_" + (Get-Date -Format s).replace(":", "-") + ".csv"
$FilePath = "$PSScriptRoot\$FileName"
$OutputType = "CSV" #OPTIONS: CSV - Outputs CSV to specified FilePath, CONSOLE - Outputs to console

$Regex1 = '^(?:tel:)?(?:\+)?(\d+)(?:;ext=(\d+))?(?:;([\w-]+))?$'
$Array1 = @()

#Get Users with LineURI
$UsersLineURI = Get-CsOnlineUser -Filter { LineURI -ne $Null } | Where-Object { $_.Department -ne "Microsoft Communication Application Instance" }
if ($UsersLineURI -ne $null) {
     foreach ($item in $UsersLineURI) {                  
          $Matches = @()
          $Item.LineURI -match $Regex1 | Out-Null
            
          $myObject1 = New-Object System.Object
          $myObject1 | Add-Member -type NoteProperty -Name "LineURI" -Value $Item.LineURI
          $myObject1 | Add-Member -type NoteProperty -Name "DDI" -Value $Matches[1]
          $myObject1 | Add-Member -type NoteProperty -Name "Ext" -Value $Matches[2]
          $myObject1 | Add-Member -type NoteProperty -Name "SipAddress" -Value $Item.SipAddress
          $myObject1 | Add-Member -type NoteProperty -Name "DisplayName" -Value $Item.DisplayName
          $myObject1 | Add-Member -type NoteProperty -Name "FirstName" -Value $Item.FirstName
          $myObject1 | Add-Member -type NoteProperty -Name "LastName" -Value $Item.LastName
          $myObject1 | Add-Member -type NoteProperty -Name "Type" -Value "User"
          $Array1 += $myObject1          
     }
}

#Get online resource accounts
$OnlineApplicationInstanceLineURI = Get-CsOnlineApplicationInstance | Where-Object { $_.PhoneNumber -ne $Null }
if ($OnlineApplicationInstanceLineURI -ne $null) {
     Write-Verbose "Processing Online Application Instances (Resource Accounts) Numbers"
     foreach ($Item in $OnlineApplicationInstanceLineURI) {                 
          $Matches = @()
          $Item.PhoneNumber -match $Regex1 | Out-Null
            
          $myObject1 = New-Object System.Object
          $myObject1 | Add-Member -type NoteProperty -Name "LineURI" -Value $Item.PhoneNumber
          $myObject1 | Add-Member -type NoteProperty -Name "DDI" -Value $Matches[1]
          $myObject1 | Add-Member -type NoteProperty -Name "Ext" -Value $Matches[2]
          $myObject1 | Add-Member -type NoteProperty -Name "DisplayName" -Value $Item.DisplayName
          $myObject1 | Add-Member -type NoteProperty -Name "SipAddress" -Value $Item.UserPrincipalName
          $myObject1 | Add-Member -type NoteProperty -Name "Type" -Value $(if ($item.ApplicationId -eq "ce933385-9390-45d1-9512-c8d228074e07") { "Auto Attendant Resource Account" } elseif ($item.ApplicationId -eq "11cd3e2e-fccb-42ad-ad00-878b93575e07") { "Call Queue Resource Account" } else { "Unknown Resource Account" })
          $Array1 += $myObject1         
     }
}

if ($OutputType -eq "CSV") {
     $Array1 | Export-Csv $FilePath -NoTypeInformation
     #$Array1 | Sort-Object -Property LineUri | Format-Table -AutoSize -Property SipAddress, LineURI, DisplayName, Type
     Write-Host -ForegroundColor Cyan "[OK] Export finished."
     Write-Host -ForegroundColor Cyan "[OK] Your file has been saved to $FilePath."
}
elseif ($OutputType -eq "CONSOLE") {
     $Array1 | Format-Table -AutoSize -Property SipAddress, LineURI, DisplayName, Type
     Write-Host -ForegroundColor Cyan "[OK] Output to console finished"
}
else {
     $Array1 | Format-Table -AutoSize -Property SipAddress, LineURI, DisplayName, Type
     Write-Host -ForegroundColor Cyan "[WARNING] Valid output type not set, defaulted to console."
}