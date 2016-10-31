#
# UCBox.ca 
# Usage report.ps1 -OrganizationUnit domain.local/OU <debug>
# Where:
#   <domain> 
# 	<debug> to enable debug just use $True
#

#Initial Settings
$vOU = $args[0]
$DebugMode = $args[2]
$vDebug = " -WarningAction SilentlyContinue"
$OfficialPath = "\\catorex10\exutil$\EXMailboxProfile.info"

#Initial Validation...
$tPath = Test-Path $OfficialPath
If ($tPath -eq $True) {
	$vFile = import-csv $OfficialPath
} Else { 
	Write-Warning "The file containing all Exchange Profile rules wasn't found it."
	Break;
}


If ($DebugMode -eq $True) {
	Write-Host "==General Settings======="
	Write-Host "Mailbox Name......:"  $vMailbox
	Write-Host "Current Profile...:"  $vProfile
	$vDebug = ""
	Write-Host "==Cmdlet Actions======="
} Else {
	Write-Host "Checking... it may take a while, go for a Starbucks! " $vMailbox
}

$vinmates = New-Object System.Collections.ArrayList


if ($vOU -ne $null) 
    { 
        $vmbx = get-mailbox -OrganizationalUnit $vOU -resultsize:unlimited
    } Else
    {
        $vmbx = get-mailbox -resultsize:unlimited
    }

ForEach ($mbx in $vmbx)
    {
        $vStatus = $False        
        #write-host "mbx" $mbx
        ForEach ($tFile in $vFile) {
	        $tValid=$False
	        Switch ($mbx.CustomAttribute6)
		        {
			        "GOLD"		{ $tValue=$tFile.GOLDValue;$tValid=$True}
			        "SILVER"  	{ $tValue=$tFile.SILVERValue; $tValid=$True}
			        "BRONZE"  	{ $tValue=$tFile.BRONZEValue; $tValid=$True}
			        default 	{ $vStatus = $True}
		        }
	        If ($tValid -eq $True) {
		        If ($DebugMode -eq $True) { Write-Host "Cmdlet....:" ($tFile.Rulecmdlet + " -Identity " + $mbx + " -" + $tFile.RuleAttribute + " " + $tValue + $vDebug) }
                Invoke-Expression ("if ((" + $tfile.Checkcmdlet + " " + $mbx + ")." + $tfile.RuleAttribute +" -ne '" + $tvalue +"') {" + '$vStatus' +" = '$true'}")
	        }
        }
    If ($vstatus -eq $True) { write-host "User processed.."; $vinmates.add($mbx.samaccountname)} 
    }

clear
Write-Host 
Write-host "List of non-compliant mailboxes based on their profiles vs features..." -ForegroundColor Yellow
Write-host
$vinmates | fl
Write-host
Write-host "For detailed information, you can run report.ps1 -details <mailbox>" 
Write-host

$vinmates | fl | Export-csv -Path "C:\Users\Administrator.MONTREALLAB.000\Documents\GitHub\EX2016\users.csv"