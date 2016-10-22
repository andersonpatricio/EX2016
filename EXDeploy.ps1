#Defaul variables
$vhost = hostname
$SourceInstall = "\\catorex01\exutil$"
$vinfo = import-csv C:\Temp\customer.info

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
write-host ".:. Exchange Server Settings (Requires Exchange Management Shell)" -foregroundcolor green
Write-host "30 - Configure Web Services"
write-host "31 - Autodiscover"
write-host "32 - License"
write-host "33 - Exchange Certificate"
write-host "34 - Outlook Settings"
write-host "35 - Message Tracking Settings"
write-host "36 - OWA Settings"
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
                Disable-NetAdapterBinding Replication01 -ComponentID ms_server
                Disable-NetAdapterBinding Replication01 -ComponentID ms_client
                Disable-NetAdapterBinding Replication01 -ComponentID ms_pacer
                Disable-NetAdapterBinding Replication02 -ComponentID ms_server
                Disable-NetAdapterBinding Replication02 -ComponentID ms_client
                Disable-NetAdapterBinding Replication02 -ComponentID ms_pacer
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

#Exchange Settings...

If ($opt -eq 30)
    {
        Set-ECPVirtualDirectory "$vhost\ECP (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/ecp") -ExternalURL ("https://" + ($vinfo).URL + "/ecp")
        Set-WebServicesVirtualDirectory "$vhost\EWS (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/EWS/Exchange.asmx") -ExternalURL ("https://" + ($vinfo).URL + "/EWS/Exchange.asmx")
        Set-ActiveSyncVirtualDirectory "$vhost\Microsoft-Server-ActiveSync (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/Microsoft-Server-ActiveSync") -ExternalURL ("https://" + ($vinfo).URL + "/Microsoft-Server-ActiveSync")
        Set-OABVirtualDirectory "$vhost\OAB (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/OAB") -ExternalURL ("https://" + ($vinfo).URL + "/OAB")
        Set-OWAVirtualDirectory "$vhost\OWA (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/OWA") -ExternalURL ("https://" + ($vinfo).URL + "/OWA")
        Set-PowerShellVirtualDirectory "$vhost\PowerShell (Default Web Site)" -InternalURL ("https://" + ($vinfo).URL + "/powershell") -ExternalURL ("https://" + ($vinfo).URL + "/powershell")
        #Ouput
        Write-Host "New settings.."
        Get-EcpVirtualDirectory "$vhost\ecp (Default Web Site)" | fl Identity,InternalURL,ExternalURL
        Get-WebServicesVirtualDirectory "$vhost\ews (Default Web Site)" | fl Identity,InternalURL,ExternalURL
        Get-ActiveSyncVirtualDirectory "$vhost\Microsoft-Server-ActiveSync (Default Web Site)" | fl Identity,InternalURL,ExternalURL
        Get-OABVirtualDirectory "$vhost\oab (Default Web Site)" | fl Identity,InternalURL,ExternalURL
        Get-OWAVirtualDirectory "$vhost\owa (Default Web Site)" | fl Identity,InternalURL,ExternalURL
        Get-PowerShellVirtualDirectory "$vhost\PowerShell (Default Web Site)" | fl Identity,InternalURL,ExternalURL
    }

If ($opt -eq 31)
    {
        write-host
        write-host "Autodiscover.. " $vhost
        Set-ClientAccessService -Identity $vhost -AutoDiscoverServiceInternalUri ($vinfo).autodiscover
        Get-ClientAccessService $vhost | Select Name,AutoDiscoverServiceInternalUri        
    }
If ($opt -eq 32)
    {
    write-host
    write-host "Applying License on the local server.. " $vhost
    set-exchangeserver $vhost -ProductKey ($vinfo).License
    write-host
    }

If ($opt -eq 33)
    {
    write-host
    write-host "Certificate.." $vhost
    Import-ExchangeCertificate -Server $vhost -FileName ($SourceInstall + "\cert.pfx") -Password (ConvertTo-SecureString -String "m@nager171" -AsPlainText -Force)
    Get-ExchangeCertificate | where-object {$_.RootCAType -eq 'ThirdParty'} | Enable-ExchangeCertificate -Services IIS
    write-host
    }
If ($opt -eq 34)
    {
    write-host
    write-host "Outlook.." $vhost
    Set-OutlookAnywhere -Identity "$vhost\rpc (Default Web Site)" -InternalHostname ($vinfo).url -ExternalHostname ($vinfo).url -ExternalClientsRequireSsl $True -ExternalClientAuthenticationMethod 'NTLM' -InternalClientsRequireSsl $True
    Get-OutlookAnywhere -Identity "$vhost\rpc (Default Web Site)" | fl Identity,InternalHostname,ExternalHostName
    write-host
    }

If ($opt -eq 35)
    {
    write-host
    write-host "Message Tracking.." $vhost
    Set-TransportService $vhost -MessageTrackingLogEnabled $True -MessageTrackingLogMaxFileSize 5MB -MessageTrackingLogMaxDirectorySize 30GB -MessageTrackingLogSubjectLoggingEnabled $True -MessageTrackingLogMaxAge 60.00:00:00
    Get-TransportService $vhost | fl MessageTrackingLogEnabled,MessageTrackingLogMaxFileSize,MessageTrackingLogMaxDirectorySize,MessageTrackingLogSubjectLoggingEnabled,MessageTrackingLogMaxAge
    write-host
    }

If ($opt -eq 36)
    {
    write-host
    write-host "OWA ..." $vhost
    Set-OWAVirtualDirectdory "$vhost\OWA*" -LogonPagePublicPrivateSelectionEnabled $True
    write-host
    }
If ($opt -eq 0)
    {
    write-host
    write-host "Goodbye! May the Force be with you"
    write-host
    }
