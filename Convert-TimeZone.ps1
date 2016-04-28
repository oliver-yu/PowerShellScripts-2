Function Convert-TimeZone 
{
    <#

        .SYNOPSIS

        Convert date time to given time zone.



        .DESCRIPTION


        This function convertes a DateTime-Object to a given time zone.



        .PARAMETER DateTime 

        A DateTime Object to convert.



        .PARAMETER ToTimeZone 

        The String representation of the time zone to convert to.



        .EXAMPLE 

        Convert-TimeZone -DateTime (Get-Date).ToUniversalTime() -ToTimeZone “W. Europe Standard Time”
        
        

        .NOTES
        
        To receive a list of all available time zones run the following command:
        [System.TimeZoneInfo]::GetSystemTimeZones() 

    #>
      
    [CmdletBinding()]            
    Param(  [Parameter(Mandatory=$true)]            
            [ValidateNotNullOrEmpty()]            
            [DateTime]$DateTime,

            [Parameter(Mandatory=$true)]            
            [ValidateNotNullOrEmpty()]              
            [String]$ToTimeZone  = ([System.TimeZoneInfo]::UTC).id            
    )            

    $ToTimeZoneObj  = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.id -eq $ToTimeZone }            
             
    [System.TimeZoneInfo]::ConvertTime($DateTime, $ToTimeZoneObj)                     
}
