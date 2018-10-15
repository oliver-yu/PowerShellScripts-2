function Convert-Umlaute 
{
    <#
        .SYNOPSIS
        Replace umlaute in strings.
        
        .DESCRIPTION
        This function replaces umlate like: Ä.Ö,Ü in strings. 
        
        .PARAMETER String
        String to replace umlaute in.
        
        .EXAMPLE 
        Convert-Umlaute "Übermäßig völlig"
    #>
    
    [CmdletBinding()]   
    Param
    (
        [Parameter(Mandatory)]
        [string]$String
    )

    $Object = New-Object PSObject | Add-Member -MemberType NoteProperty -Name Name -Value $String -PassThru
 
    $charMap = New-Object system.collections.hashtable
    $charMap.Ä = "Ae"
    $charMap.Ü = "Ue"
    $charMap.Ö = "Oe"
    $charMap.ä = "ae"
    $charMap.ü = "ue"
    $charMap.ö = "oe"
    $charMap.ß = "ss"
 
    $Object.Name | ForEach-Object { $charMap.Keys | ForEach-Object { $Object.$property = $Object.$property -creplace $_, $charMap[$_] } }
    $Object.Name
}
