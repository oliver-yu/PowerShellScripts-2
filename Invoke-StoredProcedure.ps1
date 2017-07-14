Param(  [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$Value,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$StoredProcedure
)

Function Get-ConnectionString()
{
    # Set connection string here
    return "Data Source=.;Initial Catalog=Test;Integrated Security=True"
}

Function Invoke-StoredProcedure()
{
    <#

    .SYNOPSIS

    Executes stored procedure and retreives return code.



    .DESCRIPTION

    This function runs a stored procedure on an sql server und retirevs a return code.
    Multiple values cann be passed to the stored procedure by adding more sqlcmd parameters. 



    .PARAMETER Value

    The value to pass to the stored procedure. Multiple values can be added.

    
    .PARAMETER StoredProcedure

    The name of the stored procedure to call.



    .EXAMPLE 

    Invoke-StoredProcedure -Value "Test" -StoredProcedure "TestProc"



    .NOTES

    Based on this blog post: http://ntsblog.homedev.com.au/index.php/2012/02/27/powershell-return-value-storedprocedure-executenonquery/
    The return object is of type array, last entry is the return value
 
    #>

    Param(  [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [string]$Value,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [string]$StoredProcedure
    )
     
    $connectionString = Get-ConnectionString
     
    $sqlConnection = new-object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConnection.Open() 
     
    $sqlCmd = new-object System.Data.SqlClient.SqlCommand("$($StoredProcedure)", $sqlConnection) 
 
    $sqlCmd.CommandType = [System.Data.CommandType]"StoredProcedure"
    
    # multiple parameters can be passed to the stored procedures 
    $sqlCmd.Parameters.AddWithValue("@Value", $Value)
 
    # Type of return value can be set here
    $sqlCmd.Parameters.Add("@ReturnValue", [System.Data.SqlDbType]"Int") 
    $sqlCmd.Parameters["@ReturnValue"].Direction = [System.Data.ParameterDirection]"ReturnValue"
  
    $sqlCmd.ExecuteNonQuery() | out-null
    $sqlConnection.Close() 
 
    [int]$sqlCmd.Parameters["@ReturnValue"].Value    
}

# Return object is of type array, last entry is the return value
(Invoke-StoredProcedure -Value $Value -StoredProcedure $StoredProcedure)[2]
