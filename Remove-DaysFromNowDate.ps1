<#
.SYNOPSIS
    Generates date from today with subsctracted number of days.

.DESCRIPTION
    Generate a date with substracted number of days from the current date.

.PARAMETER DaysToRemove
    The number of days to substract from the current date.

.EXAMPLE
    Remove-DaysFromNowDate(9)
    Remove-DaysFromNowDate -DaysToRemove 12 

.NOTES
    Date format will be like: 2017-10-22
#>
function Remove-DaysFromNowDate {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int] 
        $DaysToRemove
        )

    (Get-Date).AddDays(($DaysToRemove * -1)).ToString('yyyy-MM-dd')
}

Remove-DaysFromNowDate(6)