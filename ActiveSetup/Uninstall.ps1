<#

    .SYNOPSIS

    Active setup uninstall script.



    .DESCRIPTION


    Use this template for performing actions for users currently logged in during uninstallation.
    Parameters are automatically passed by the main script.



    .PARAMETER Username 

    Name of the currently logged in user.



    .PARAMETER SID 

    SID of the currently logged in user.

    
#>

param ( [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$Username,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$SID
)
