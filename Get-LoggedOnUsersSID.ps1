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
    $userNames = @()

    Foreach ($id in @((Get-WmiObject -Class Win32_LogonSession -ComputerName "." | Where-Object { $_.LogonType -eq 2 -or $_.LogonType -eq 10 }).LogonId) ) 
    {  
        $UserInfo = (Get-WmiObject Win32_LoggedOnUser | Where-Object { $_.Dependent -like "*$($id)*"  }).Antecedent

        $UserInfo -match $regexDomain > $nul
        $UserName = $matches[1] + "\" + $matches[2]
        
        $User = New-Object System.Security.Principal.NTAccount($UserName)
    
        if ($userNames -contains $User)
        {
            continue
        }
        else
        {
            $userNames += $User
        }
    
        $loggedOnUser = New-Object -TypeName PsObject
        $loggedOnUser | Add-Member -MemberType NoteProperty -Name "UserName" -Value $User
        $loggedOnUser | Add-Member -MemberType NoteProperty -Name "SID" -Value (Normalize-SID -SID $User.Translate([System.Security.Principal.SecurityIdentifier]).value)
        $loggedOnUser
    }
}
