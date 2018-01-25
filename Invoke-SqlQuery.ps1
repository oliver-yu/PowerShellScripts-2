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
    
    $serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SqlServerName)

    try 
    {
        $reader = $ServerConnection.ExecuteReader($QueryString)
        Write-Host "Query '$QueryString' successfully executed." -ForegroundColor Cyan
        $result = $reader | ForEach-Object {$a = @{}; for ($i = 0; $i -lt $Reader.FieldCount; $i++) { $a.Add($Reader.GetName($i), $_.GetValue($i))}; $a}
	    $serverConnection.Disconnect()
        return $result
    } 
    catch 
    {
        Write-Host $_.Exception.ToString() -ForegroundColor Red
        $reader.Close()
        $reader.Dispose()
        return $null
    }    
}
