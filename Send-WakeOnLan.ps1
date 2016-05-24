Function Send-WakeOnLan
{ 
    <#

        .SYNOPSIS

        Send wake on lan request.



        .DESCRIPTION

        This function sends a wake on lan request to a given mac address.



        .PARAMETER MAC

        Mac address to send the package to.


        .PARAMETER Subnetmask (optional)

        Subnetmask of the client.


        .PARAMETER Port (optional)

        Port to send the package to. Default is 9.



        .EXAMPLE 

        Send-WakeOnLan -MAC 32:00:6A:5D:3B:1C

    #>

    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True)] 
        [string]$MAC, 
        [string]$Subnetmask = "255.255.255.255",  
        [int]$Port = 9 
    )
 
    $Broadcast = [Net.IPAddress]::Parse($Subnetmask) 
  
    $MAC=(($MAC.replace(":", "")).replace("-", "")).replace(".", "") 
    $Target = 0,2,4,6,8,10 | % {[convert]::ToByte($MAC.substring($_, 2), 16)} 
    $Packet = (,[byte]255 * 6) + ($Target * 16) 
  
    $UDPclient = new-Object System.Net.Sockets.UdpClient 
    $UDPclient.Connect($Broadcast, $Port) 
    [void]$UDPclient.Send($Packet, 102)  
} 
