#
# UCBox.ca 
# Usage report.ps1 domain.local/OU
# Where:
#   <domain> 
#

#Initial Settings
$vOU = $args[0]
$DebugMode = $args[2]
$vDebug = " -WarningAction SilentlyContinue"
$OfficialPath = "\\catorex10\exutil$\EXMailboxProfile.info"
$vinmates = New-Object System.Collections.ArrayList

#Initial Validation...
$tPath = Test-Path $OfficialPath
If ($tPath -eq $True) {
	$vFile = import-csv $OfficialPath
} Else { 
	Write-Warning "The file containing all Exchange Profile rules wasn't found it."
	Break;
}

Write-Host "Checking... it may take a while, go for a Starbucks! " $vMailbox

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


If ($vinmates -ne $null) 
        {
            ForEach ($tmbx in $vinmates) 
	            {
                Write-host
                write-host '--Mailbox...:' $tmbx.Name -ForegroundColor Yellow
                if ($tmbx.CustomAttribute6 -eq $null) {Write-Host "No Profile associated to this mailbox"}
                $tValid=$False
                ForEach ($tFile in $vFile)
                    {
	                Switch ((get-mailbox $tmbx).CustomAttribute6)
		                {
			                "GOLD"		{ $tValue=$tFile.GOLDValue;$tValid=$True}
			                "SILVER"  	{ $tValue=$tFile.SILVERValue; $tValid=$True}
			                "BRONZE"  	{ $tValue=$tFile.BRONZEValue; $tValid=$True}
			                default 	{ Break}
		                }
	                If ($tValid -eq $True) 
                        {
                        Invoke-Expression ("if ((" + $tfile.Checkcmdlet + " " + $tmbx + ")." + $tfile.RuleAttribute +" -ne '" + $tvalue +"') { write-host 'Rule Name...:'" + $tfile.RuleName + " ' - Status: Not Compliant!'}")
	                    }
                    }
                }
        }