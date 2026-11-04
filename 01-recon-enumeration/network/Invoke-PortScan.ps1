# .\Invoke-PortScan.ps1 -CIDR 172.16.2.0/24
param(
    [Parameter(Mandatory=$true)]
    [string]$CIDR
)

# Puertos habituales en entornos Windows/AD
$Ports = @(
    53,     # DNS
    80,     # HTTP
    88,     # Kerberos
    135,    # RPC
    139,    # NetBIOS
    389,    # LDAP
    443,    # HTTPS
    445,    # SMB
    464,    # Kerberos Password
    636,    # LDAPS
    1433,   # MSSQL
    3268,   # Global Catalog
    3269,   # Global Catalog SSL
    3389,   # RDP
    5985,   # WinRM HTTP
    5986,   # WinRM HTTPS
    8080,   # HTTP Alternate
    8443,   # HTTPS Alternate
    9389    # AD Web Services
)

function Convert-CIDRToIPs {

    param([string]$CIDR)

    $network,$prefix = $CIDR.Split('/')

    $bytes = [System.Net.IPAddress]::Parse($network).GetAddressBytes()
    [Array]::Reverse($bytes)
    $ip = [BitConverter]::ToUInt32($bytes,0)

    $mask = [uint32]([math]::Pow(2,32)-[math]::Pow(2,(32-$prefix)))
    $networkIP = $ip -band $mask
    $broadcast = $networkIP + ([math]::Pow(2,(32-$prefix))-1)

    for($i=$networkIP+1;$i -lt $broadcast;$i++)
    {
        $b = [BitConverter]::GetBytes([uint32]$i)
        [Array]::Reverse($b)
        ([System.Net.IPAddress]$b).IPAddressToString
    }
}

function Test-Port {

    param(
        [string]$IP,
        [int]$Port
    )

    try{
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($IP,$Port,$null,$null)

        if($iar.AsyncWaitHandle.WaitOne(250,$false))
        {
            $client.EndConnect($iar)
            $client.Close()
            return $true
        }

        $client.Close()
        return $false
    }
    catch{
        return $false
    }
}

$Hosts = Convert-CIDRToIPs $CIDR

foreach($HostIP in $Hosts)
{
    $Open = @()

    foreach($Port in $Ports)
    {
        if(Test-Port $HostIP $Port)
        {
            $Open += $Port
        }
    }

    if($Open.Count -gt 0)
    {
        Write-Host "$HostIP`t$($Open -join ', ')" -ForegroundColor Green
    }
}