Function Invoke-SqlQuery
{
    <#

        .SYNOPSIS

        Execute sql query.



        .DESCRIPTION

        Short function to execute an sql query.
        


        .PARAMETER SqlServerName 

        Name of the sql server to connect to.



        .PARAMETER QueryString 

        Sql query to be executed.



        .EXAMPLE 

        Invoke-SqlQuery -SqlServerName "SqlServer001" -QueryString "SELECT TOP 1000 * FROM [Db1].[dbo].[Table1]"



        .NOTES

        Links: https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.common.serverconnection.aspx 

    #>

    [cmdletbinding()]
    Param(  [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]
            [string]$SqlServerName,
        
            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]  
            [string]$QueryString
    )

    # Reqiures Microsoft.SqlServer.ConnectionInfo.dll; See link above.
    [void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")
    
    $ServerConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SqlServerName)

    try 
    {
        $Reader = $ServerConnection.ExecuteReader($QueryString)
        Write-Host "Query '$QueryString' successfully executed." -ForegroundColor Cyan
        return $Reader
    } 
    catch 
    {
        Write-Host $_.Exception.ToString() -ForegroundColor Red
        $Reader.Close()
        $Reader.Dispose()
        return $null
    }    
}
