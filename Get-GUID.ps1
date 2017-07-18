function Get-GUID
{
    <#
        .SYNOPSIS
            Generates a new GUID.

        .DESCRIPTION
            Generates a new 32 Bit GUID.

        .PARAMETER AddBraces
            Adds braces surrounding the GUID.

        .PARAMETER RemoveHyphen
            Removes the hyphens.

        .PARAMETER Uppercase
            Returns only upper case letters.

        .EXAMPLE 
            Get-GUID
            Get-GUID -AddBraces -Uppercase

    #>

    Param([switch]$AddBraces,
        [switch]$RemoveHyphens,
        [switch]$Uppercase
    )

    $guid = (New-Guid).Guid

    if ($Uppercase)
    {
        $guid = $guid.ToUpper()
    }

    if ($AddBraces)
    {
        $guid = '{' + $guid + '}'
    }

    if ($RemoveHyphens)
    {
        $guid = $guid.Replace('-', '')
    }

    $guid
}

Get-GUID