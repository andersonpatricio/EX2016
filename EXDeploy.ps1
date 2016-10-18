clear
Write-host "Exchange Deployment Tool" -ForegroundColor Yellow
Write-Host
Write-host "1 - Exchange 2016 CU3 - Download"
write-host "2 - Unified Communications Managed API 4.0 Runtime - Download"
write-host "3 - Exchange Requirements with restart"
write-host "4 - Exchange 2013 installation"
write-host
Write-Host 0 - Operator or Exit
write-host
$opt = Read-Host -Prompt "Select your option"

#Preparing the environment..
$vPath = "C:\Temp\"
If (Test-Path $vPath) {} Else{New-Item -Path C:\Temp -ItemType Directory}

If ($opt -eq 1)
    {
    write-host
    write-host "Exchange 2013 CU13 - Download"
    $source = "https://download.microsoft.com/download/7/4/9/74981C3B-0D3C-4068-8272-22358F78305F/Exchange2013-x64-cu13.exe"
    $destination = "c:\Temp\EX2013-cu13.exe"
    Invoke-WebRequest $source -OutFile $destination    
    C:\Temp\EX2013-cu13.exe /extract:C:\EX2013
    write-host
    }


If ($opt -eq 2)
    {
    write-host
    write-host "Downloading... - Unified Communications Managed API 4.0 Runtime"
    $source = "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
    $destination = "c:\Temp\UCMARuntimeSetup.exe"
    Invoke-WebRequest $source -OutFile $destination    
    write-host
    write-host "Extracting... - Unified Communications Managed API 4.0 Runtime"
    c:\Temp\UCMARuntimeSetup.exe /q
    write-host
    }

If ($opt -eq 3)
    {
    write-host
    write-host "Exchange Requirements with restart"
    Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS, telnet-client
    Restart-Server    
    write-host
    }

If ($opt -eq 4)
    {
    write-host
    write-host "Installing ... - Exchange Server 2013 CU13"
    "c:\EX2013\Setup.exe /Mode:Install /Roles:Mailbox,ClientAccess /MDBName:DB01 /IAcceptExchangeServerLicenseTerms"
    write-host
    }

    If ($opt -eq 0)
    {
    write-host
    write-host "Goodbye! May the Force be with you"
    write-host
    }
