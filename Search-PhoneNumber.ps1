<#
.SYNOPSIS
Microsoft Teams - Search for a specific phonenumber in your Microsoft365 tenant.

.Description
This script will search the phonenumber entered when running the script.

UPDATES:
1.0     > initial setup of the script.

.NOTES
  Version      	   		: 1.0
  Author(s)    			: Erwin Bierens
  Email/Blog/Twitter	: erwin@bierens.it https://erwinbierens.com @erwinbierens

.EXAMPLE
.\Search-phonenumber.ps1 -PhoneNumber +3188446xxxx

.EXAMPLE
.\Search-phonenumber.ps1

#>
#Requires -Version 3.0

# Functions
# file path in cmdlet
[CmdletBinding(SupportsShouldProcess = $True)]
param(
    # Defines the Source file.
    [parameter(ValueFromPipelineByPropertyName = $True)]
    [string] $PhoneNumber

)

Write-Host -ForegroundColor Cyan "[OK] Loading Script.."

If (($PhoneNumber)) {
    Write-Host -ForegroundColor Cyan "[OK] Phonenumber detected.."
    Get-CsOnlineUser -WarningAction silentlyContinue | Where-Object { $_.LineUri -contains ("tel:" + "$PhoneNumber") } | Format-List DisplayName,SipAddress,UserPrincipalName,LineUri,OnlineVoiceRoutingPolicy, EnterpriseVoiceEnabled
}

else {
    Write-Host -ForegroundColor Cyan "[INFO] No phonenumber detected"
    $UPN = Read-Host "Please enter the phonenumber in E164 format (+31..)"
    Get-CsOnlineUser -WarningAction silentlyContinue | Where-Object { $_.LineUri -contains ("tel:" + "$UPN") } | Format-List DisplayName,SipAddress,UserPrincipalName,LineUri,OnlineVoiceRoutingPolicy, EnterpriseVoiceEnabled
}