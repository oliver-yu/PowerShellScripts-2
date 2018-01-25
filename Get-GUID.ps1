function Get-GUID
{
    <#
        .SYNOPSIS
            Generates a new GUID.

        .DESCRIPTION
            Generates a new 128 Bit GUID.

        .PARAMETER AddBraces
            Adds braces surrounding the GUID.

        .PARAMETER RemoveHyphen
            Removes the hyphens.

        .PARAMETER Uppercase
            Returns GUID with all upper case letters.

        .PARAMETER Amount
            Number of guids to create. If not set a single GUID is created.

        .EXAMPLE 
            Get-GUID
            Get-GUID -AddBraces -Uppercase
    #>

    Param([switch]$AddBraces,
          [switch]$RemoveHyphens,
          [switch]$Uppercase,
          [int]$Amount
    )

    if (!$Amount -or $Amount -le 1) 
    {
        $Amount = 1
    }

    foreach ($i in 1..$Amount) 
    {
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
}

Get-GUID
