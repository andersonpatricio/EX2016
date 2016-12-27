#Defaul variables for the script
$vhost = hostname

clear
Write-host
Write-host "Windows Server 2016 - Admin Toolbox" -ForegroundColor Yellow
Write-Host
write-host ".:. OS Settings" -foregroundcolor green
Write-host "1 - Network adjustments"
Write-host "2 - Time Zone"
Write-Host "3 - Pagefile configuration"
Write-host "4 - Clear Event Viewer" 
Write-host "5 - Disable IPv6 Transition Protocols"
Write-host "6 - Startup Time"
Write-host "7 - Server Information"
Write-Host "8 - Power Savings" 
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
        get-netadapter LAN -ErrorAction SilentlyContinue -ErrorVariable erNet
        If ($ernet.count -ne 0) { $vStatus = 1}
        #get-netadapter Replication01 -ErrorAction SilentlyContinue -ErrorVariable erNet

        If ($vStatus -eq 1) { Write-Host "The adapters are not in compliance with the Windows Server desing. A LAN must exist."}
	        Else {
                Write-Host "Configuring Network Adapters..." 
                Get-NetAdapter | Where-Object {$_.Name -ne "LAN"} | ForEach { Get-netadapter $_.Name | Set-DnsClient -RegisterThisConnectionsAddress $false }
		        wmic /interactive:off nicconfig where tcpipnetbiosoptions=0 call SetTcpipNetbios 2
		        write-host "All additional NIC adapters were configured based on the corporate policy!"
	        }
    }

If ($opt -eq 2)
    {
        write-host "Current Time Zone on server: "
        Write-Host "New Time Zone configured based on the design:" 
        $vCountry = $vhost.Substring(0,2).ToUpper()
        write-host $vCountry
        if ($vCountry -eq 'CA') { tzutil /s "Eastern Standard Time" }
        if ($vCountry -eq 'BR') { tzutil /s "E. South America Standard Time" }
        if ($vCountry -eq 'US') { tzutil /s "Pacific Standard Time" }
        if ($vCountry -eq 'CL') { tzutil /s "Pacific Standard Time" }
        if ($vCountry -eq 'AR') { tzutil /s "Argentina Standard Time" }
     
    }

If ($opt -eq 3)
    {
        Write-host "Configuring the pagefile based on the design.. restart required afterwards"
        Set-CimInstance -Query "SELECT * FROM Win32_computersystem" -Property @{AutomaticManagedPageFile="False"}
        Set-CimInstance -Query "SELECT * FROM Win32_PageFileSetting" -Property @{InitialSize=32768;MaximumSize=32778}
    }

If ($opt -eq 4)
    {
        write-host "Cleaning up all Event Viewer from the local server.." 
        wevtutil el | Foreach { wevtutil cl "$_" }
    }


If ($opt -eq 5)
    {
        write-host "Disabling IPv6 Transition Protocols" 
        Set-Net6to4Configuration -State Disabled
        Set-NetIsatapConfiguration -State Disabled
        Set-NetTeredoConfiguration -Type Disabled
    }

If ($opt -eq 6)
    {
        write-host "Startup Time settings..." 
        bcdedit /timeout 10
    }

If ($opt -eq 7)
    {
        write-host "Configure Server Info" 
        If (Test-Path "hklm:\SOFTWARE\Yamana") {} Else {New-Item -path hklm:\SOFTWARE -Name Yamana -Force}
        New-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "Service" -PropertyType:String -ErrorAction SilentlyContinue
        New-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "ServiceOwner" -PropertyType:String  -ErrorAction SilentlyContinue
        New-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "ServerType" -PropertyType:MultiString  -ErrorAction SilentlyContinue
        Write-Host
        Write-Host "Server Information:" -ForegroundColor Cyan
        Write-Host
        $vService = Read-Host -Prompt "Service............."
        $vServiceOwner = Read-Host -Prompt "Service Owner......."
        $vMServerType = Read-Host -Prompt "Server Type (VM or Serial Number)..:"

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "Service" -Value $vService
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "ServiceOwner" -Value $vServiceOwner
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Yamana" -Name "ServerType" -Value $vServerType

    }

If ($opt -eq 8)
    {
    write-host
    write-host "Adjusting Power Savings to High Peformance based on the corporate settings.."
    powercfg /SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    write-host
    }




If ($opt -eq 0)
    {
    write-host
    write-host "Goodbye! May the Force be with you"
    write-host
    }
