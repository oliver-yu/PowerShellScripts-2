Function Send-WakeOnLan
{ 
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True,Position=1)] 
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
