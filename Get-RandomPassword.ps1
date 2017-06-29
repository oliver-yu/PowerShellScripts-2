function Get-RandomPassword {
    <#
    .SYNOPSIS
        Generates a random password with variable length.

    .DESCRIPTION
        Generates a random password with a length of six characters at least. Every password will 
        contain numbers, special signs and one or more lower and upper case letters.

    .PARAMETER Length
        Length of the password. Minimum length is 6. Any length value smaller than 6 will return a 
        six character password.

    .EXAMPLE
        Get-RandomPassword(9)
        Get-RandomPassword -Length 12 

    .NOTES

    #>
    
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int] 
        $Length
        )

    $minPasswordLength = 6
    if ($Length -lt $minPasswordLength) {$Length = $minPasswordLength}

    $numberCount = [Math]::Round($Length / 4)
    $signCount = [Math]::Round($Length / 5)
    $letterCount = $Length - $numberCount - $signCount
    $numbers = Get-Random -InputObject (0..9) -Count $numberCount
    $letters = ((65..90) + (97..122) | Get-Random -Count $letterCount | ForEach-Object {[char]$_})
    $signs = Get-Random -InputObject -,_,§,!,=,%,?,$,+ -Count $signCount

    -join (($numbers + $letters + $signs) | Sort-Object {Get-Random})
}

Get-RandomPassword(12)
