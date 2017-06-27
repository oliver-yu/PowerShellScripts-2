<#
.SYNOPSIS
    Generates date from today with added numbers of days.

.DESCRIPTION
    Generate a date with additional days to add to the current date.

.PARAMETER DaysToAdd
    The number of days to add to the current date.

.EXAMPLE
    Add-DaysToNowDate(9)
    Add-DaysToNowDate -DaysToAdd 12 

.NOTES
    Date format will be like: 2017-10-22
#>
function Add-DaysToNowDate {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int] 
        $DaysToAdd
        )

    (Get-Date).AddDays($DaysToAdd).ToString('yyyy-MM-dd')
}

Add-DaysToNowDate(6)