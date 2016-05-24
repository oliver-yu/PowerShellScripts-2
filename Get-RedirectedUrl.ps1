Function Get-RedirectedUrl 
{ 
    <#

        .SYNOPSIS

        Get redirected url..



        .DESCRIPTION

        This function gets the redirected url of a link.



        .PARAMETER URL

        Url to get the redirected url from.



        .EXAMPLE 

        Get-RedirectedUrl -URL "https://go.microsoft.com/fwlink/?LinkId=532606&clcid=0x409"

    #>

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
