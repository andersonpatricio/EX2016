#Defaul location
$SourceInstall = "\\catorex01\exutil$"
clear
Write-host "Exchange Deployment Tool" -ForegroundColor Yellow
Write-Host
write-host ".:. OS Settings" -foregroundcolor green
Write-host "1 - Network adjustments"
Write-host "2 - PageFile "
Write-Host
write-host ".:.Exchange Server 2016" -foregroundcolor green
Write-host "10 - Exchange 2016 - Installation files.. <Copy Only>"
write-host "11 - Exchange 2016 - OS requirements with restart"
write-host "12 - Exchange 2016 - Deployment"
write-host
write-host ".:. Office Online Server" -foregroundcolor green
write-host "20 - OOS - Prequisites"
write-host
write-host ".:. Exchange Server Settings" -foregroundcolor green
Write-host "30 - Configure Web Services"
write-host "31 - Configure Outlook Web App"
write-host "32 - xx"
write-host 
write-host
Write-Host 0 - Operator or Exit
write-host
$opt = Read-Host -Prompt "Select your option"

#Preparing the environment..
$vPath = "C:\Temp\"
If (Test-Path $vPath) {} Else{New-Item -Path C:\Temp -ItemType Directory}

If ($opt -eq 1)
    {
        Write-Host "Current Network Adapters in this server.."
        $vStatus = 0
        get-netadapter MAPI -ErrorAction SilentlyContinue -ErrorVariable erNet
        If ($ernet.count -ne 0) { $vStatus = 1}
        get-netadapter Replication01 -ErrorAction SilentlyContinue -ErrorVariable erNet
        If ($ernet.count -ne 0) { $vStatus = 1}
        #get-netadapter Replication02 -ErrorAction SilentlyContinue -ErrorVariable erNet
        #If ($ernet.count -ne 0) { $vStatus = 1}

        If ($vStatus -eq 1) { Write-Host "The adapters are not in compliance with the Exchange Design"}
	        Else {
		        Write-Host "Configuring Network Adapters..." 
		        Get-netadapter Replication01 | Set-DNSClient -RegisterThisConnectionAddress:$False
		        Get-netadapter Replication02 | Set-DNSClient -RegisterThisConnectionAddress:$False
		        wmic /interactive:off nicconfig where tcpipnetbiosoptions=0 call SetTcpipNetbios 2
		        write-host "all good!"
	        }
    }


If ($opt -eq 10)
    {
    write-host
    write-host "Exchange 2016 - Installation Files.. copying from the source (it may take a while..) go for a Tim's"
    If (Test-Path "C:\temp\EX2016") {} Else{New-Item -Path C:\Temp\EX2016 -ItemType Directory}
    Copy-Item ($SourceInstall + "\Deployment\*") C:\Temp\EX2016\ -Recurse -Force
    write-host
    }


If ($opt -eq 11)
    {
    write-host
    write-host "Exchange Requirements with restart"
    Install-WindowsFeature NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS, Telnet-Client
    Restart-Computer -Force    
    write-host
    }

If ($opt -eq 12)
    {
    write-host
    write-host "Installing ... - Exchange Server 2016"
    c:\Temp\EX2016\Setup.exe /Mode:Install /Roles:Mailbox /MDBName:Temp01 /IAcceptExchangeServerLicenseTerms /DisableAMFiltering /InstallWindowsComponents /CustomerFeedbackEnabled:False
    write-host
    }

If ($opt -eq 20)
    {
    write-host
    write-host "Installing ... - OOS Prerequisites"
    Install-WindowsFeature Web-Server, Web-Mgmt-Tools, Web-Mgmt-Console, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Static-Content, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, InkandHandwritingServices, Windows-Identity-Foundation
    write-host
    }


If ($opt -eq 0)
    {
    write-host
    write-host "Goodbye! May the Force be with you"
    write-host
    }
