#
# Configure a mailbox to a profile
# Usage Configure-Mailbox <mailbox> <profile> <debug>
# Where:
# 	<mailbox> mailbox identification, example: anderson.patricio
# 	<profile> the possible values are Gold,Silver and Bronze
# 	<debug> to enable debug just use $True
#

#Initial Settings
$vMailbox = $args[0]
$vProfile = $args[1].ToUpper()
$DebugMode = $args[2]
$vDebug = " -WarningAction SilentlyContinue"
$OfficialPath = "\\apatricio.local\NETLOGON\EXMailboxProfile.info"

#Initial Validation...
$tPath = Test-Path $OfficialPath
If ($tPath -eq $True) {
	$vFile = import-csv $OfficialPath
} Else { 
	Write-Warning "The file containing all Exchange Profile rules wasn't found it."
	Break;
}


If (($args[0] -eq $null ) -or ($args[1] -eq $null)){
	Write-Warning "You need to provide a mailbox and profile."
	Write-Warning "Example: Assign-Profile.ps1 Anderson.Patricio Gold"
	Break; 
}
If (((Get-Mailbox -Identity $vMailbox -ErrorAction 'SilentlyContinue').IsValid) -eq $null) {
	Write-Warning "The specified Mailbox cannot be found."
	Break;
}

If ( ($vProfile -ne "GOLD") -and ($vProfile -ne "BRONZE") -and ($vProfile -ne "SILVER") ) {
	Write-Warning "Use a valid profile!!"
	Write-Warning "Possible values are: gold, silver, and bronze."
	Break;
}

If ($DebugMode -eq $True) {
	Write-Host "==General Settings======="
	Write-Host "Mailbox Name......:"  $vMailbox
	Write-Host "Current Profile...:"  $vProfile
	$vDebug = ""
	Write-Host "==Cmdlet Actions======="
} Else {
	Write-Host "Modifying... " $vMailbox
}

ForEach ($tFile in $vFile) {
	$tValid=$False
	Switch ($vProfile)
		{
			"GOLD"		{ $tValue=$tFile.GOLDValue;$tValid=$True}
			"SILVER"  	{ $tValue=$tFile.SILVERValue; $tValid=$True}
			"BRONZE"  	{ $tValue=$tFile.BronzeValue; $tValid=$True}
			default 	{ write-host "Mailbox does not have a valid Profile"}
		}
	If ($tValid -eq $True) {
		If ($DebugMode -eq $True) { Write-Host "Cmdlet....:" ($tFile.Rulecmdlet + " -Identity " + $vMailbox + " -" + $tFile.RuleAttribute + " " + $tValue + $vDebug) }
		Invoke-Expression ($tFile.Rulecmdlet + " -Identity " + $vMailbox + " -" + $tFile.RuleAttribute + " " + $tValue + $vDebug)		
		Set-Mailbox $vMailbox -CustomAttribute6 $vProfile -WarningAction SilentlyContinue
	}
}