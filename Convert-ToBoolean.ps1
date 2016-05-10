Function Convert-ToBoolean
{
    <#

    .SYNOPSIS

    Converts strings into boolean.



    .DESCRIPTION

    The function converts multiple string expressions into a boolean. Even &null Values are handeld.



    .PARAMETER Value 

    String to convert.



    .EXAMPLE 

    Convert-ToBoolean -Value $null


    #>

    [CmdLetBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [string] $Value
    )

    Switch ($Value.ToLower())
    {
        "y" { return $true; }
        "yes" { return $true; }
        "true" { return $true; }
        "t" { return $true; }
        "j" { return $true; }
        "ja"{ return $true; }
        1 { return $true; }
       
        "" { return $false }
        "n" { return $false; }
        "no" { return $false; }
        "nein" { return $false; }
        "false" { return $false; }
        "f" { return $false; } 
        0 { return $false; }
    }
}
