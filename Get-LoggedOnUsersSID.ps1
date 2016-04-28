Function Normalize-SID 
{
        <#

    .SYNOPSIS

    Normalizes given SID.



    .DESCRIPTION


    Removes leading and trailing brakets of a given SID.



    .EXAMPLE 

    Normalize-SID

    
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]  
            [string]$SID
    )
    
    if ($SID.StartsWith("{")) 
    {
        $SID = $SID.TrimStart("{")
    }
    
    if ($SID.EndsWith("}")) 
    {
        $SID = $SID.TrimEnd("}")
    }
    
    return $SID
}

Function Get-LoggedOnUsersSID 
{
    <#

    .SYNOPSIS

    Retrieves logged on users names and SIDs.



    .DESCRIPTION


    This functions retrieves all currently logged on users on a computer an returns thier names and SIDs.



    .EXAMPLE 

    Get-LoggedOnUsersSID



    .NOTES

    Logon type 2 and 10 checking for local and RDP connections.

    
    #>
    

    $regexDomain = '.+Domain="(.+)",Name="(.+)"$'
    $regexLogin = '.+LogonId="(\d+)"$'
    $logonSessions = @(Get-WmiObject Win32_LogonSession | Where-Object -FilterScript { $_.LogonType -eq '2' -or $_.LogonType -eq '10' })
    $logonUsers = @(Get-WmiObject Win32_LoggedOnUser)
    $sessionUser = @{}
    $arrNames = @()

    $logonUsers | % {
        $_.antecedent -match $regexDomain > $nul
        $username = $matches[1] + "\" + $matches[2]
        $_.dependent -match $regexLogin > $nul
        $session = $matches[1]
        $sessionUser[$session] += $username  
    }

    $logonSessions | % {
        $name = $sessionUser[$_.logonid]
        
        if ($arrNames -notcontains $name) 
        {
            $arrNames += $name
            $SID = Get-WmiObject Win32_UserAccount | Where-Object -FilterScript { $_.Caption -eq $name }
            
            if ($SID) 
            {
                $loggedOnUser = New-Object -TypeName PsObject
                $loggedOnUser | Add-Member -MemberType NoteProperty -Name "UserName" -Value $sessionUser[$_.logonid]
                $loggedOnUser | Add-Member -MemberType NoteProperty -Name "SID" -Value $(Normalize-SID -SID $SID.SID) 
                $loggedOnUser
            }
        }
    }
}

Get-LoggedOnUsersSID
