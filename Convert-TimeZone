Function Convert-TimeZone 
{  
    [CmdletBinding()]            
    Param(  [Parameter(Mandatory=$true)]            
            [ValidateNotNullOrEmpty()]            
            [DateTime]$DateTime,
            [parameter( Mandatory=$true)]            
            [ValidateNotNullOrEmpty()]   
            [String]$ToTimeZone  = ([System.TimeZoneInfo]::UTC).id            
    )            

    $ToTimeZoneObj  = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.id -eq $ToTimeZone }            
             
    [System.TimeZoneInfo]::ConvertTime($DateTime, $ToTimeZoneObj)                     
}

$DateTime = Convert-TimeZone -DateTime (Get-Date).ToUniversalTime() -ToTimeZone “W. Europe Standard Time” 
$DateTime.ToString("dd.MM.yyyy - HH:mm:ss")
