<#
.SYNOPSIS
Microsoft Teams - Import Users with PhoneNumbers and VoicePolicy to Microsoft365

.Description
This script will provision mulitple users with a LineUri and VoicePolicy in Microsoft Teams
Make sure the CSV contains the following columns: SipAddress,LineUri,VoicePolicy

UPDATES:
1.0     > initial setup of the script.

.NOTES
  Version      	   		: 1.0
  Author(s)    			: Erwin Bierens
  Email/Blog/Twitter	: erwin@bierens.it https://erwinbierens.com @erwinbierens

.EXAMPLE
.\Import-Users.ps1 -FilePath Users.csv

#>
#Requires -Version 3.0

# Functions
# file path in cmdlet
[CmdletBinding(SupportsShouldProcess = $True)]
param(
    # Defines the Source file.
    [parameter(ValueFromPipelineByPropertyName = $True)]
    [string] $FilePath

)

Write-Host "----------------------------------------------------------------------------------------------"
Write-Host "------------------------Microsoft Teams PhoneNumber Assignment Tool---------------------------"
Write-Host "----------------------------------------------------------------------------------------------"
Write-Host -ForegroundColor Cyan "[OK] Loading Script"

Import-Module MicrosoftTeams
Write-Host -ForegroundColor Cyan "[OK] MicrosoftTeams Module imported"
try { 
	$test = (Get-CsTenant -WarningAction silentlyContinue -ErrorAction Stop | Select-Object DisplayName)
	Write-Host -ForegroundColor Cyan "[OK] You are connected to Microsoft Teams"
	Write-Host -ForegroundColor Cyan "[OK] Tenant: $($test.DisplayName)"
} 
catch [System.UnauthorizedAccessException] { 
	Write-Host -ForegroundColor white "[ERROR] You are NOT connected to Microsoft Teams" -BackgroundColor Red
	Write-Host -ForegroundColor Cyan "[OK] Connecting to Microsoft Teams"
	Connect-MicrosoftTeams
}

Import-Csv $FilePath | ForEach-Object {

    $user = Get-CsOnlineUser -Identity $_.SipAddress | Select-Object DisplayName, SipAddress, AssignedPlan, TeamsUpgradeEffectiveMode, HostingProvider, InterpretedUserType, EnterpriseVoiceEnabled, HostedVoicemail, OnPremLineURI, OnlineVoiceRoutingPolicy, VoicePolicy, MCOValidationError
    Write-Host -ForegroundColor green "****************************************"
    Write-Host -ForegroundColor green "Starting Migration for user: $($user.DisplayName) "


    #Assign LineUri and EnterpriseVoice mode
    try {
        Set-CsPhoneNumberAssignment -Identity $_.SipAddress -PhoneNumber $_.LineUri -PhoneNumberType "DirectRouting" -ErrorAction Stop
    }
    catch {
        Write-Warning "Could not set LineURI.. ($_)"
    }

    #set online voice routing policy
    try {
        Grant-CsOnlineVoiceRoutingPolicy -Identity $_.SipAddress -PolicyName $_.VoicePolicy -Confirm:$False -ErrorAction Stop
    }
    catch {
        Write-Warning "Could not set Online Voice Routing Policy.. ($_)"
    }
    Write-Host -ForegroundColor green "$($user.DisplayName) is migrated to Teams"
    Write-Host -ForegroundColor green "****************************************"
}

Disconnect-MicrosoftTeams
Write-Host -ForegroundColor Cyan "[OK] Disconnecting Microsoft Teams"