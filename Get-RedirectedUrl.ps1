Function Get-RedirectedUrl 
{
    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )
 
    $Request = [System.Net.WebRequest]::Create($URL)
    $Request.AllowAutoRedirect = $false
    $Response = $Request.GetResponse()

    If (($Response.StatusCode -ge 300 -and $Response.StatusCode -lt 400))
    {
        $Response.GetResponseHeader("Location")
    }
}
