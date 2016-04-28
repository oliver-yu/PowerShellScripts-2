Function Deploy-SsisPackage 
{
    <#

        .SYNOPSIS

        Deploy SSIS Package.



        .DESCRIPTION


        This function deploys an SSIS package to an SQL Server.



        .PARAMETER SqlServerName 

        Name of the SQL server, deploying the package to.



        .PARAMETER IspacPath 

        Path to local SSIS Package.



        .PARAMETER ProjectName 

        Name of the projekt.



        .PARAMETER FolderName 

        Name of the folder, deploying the package into.



        .EXAMPLE 

        Deploy-SsisPackage -SqlServerName "MySqlServer001" -IspacPath "C:\Tools\test.dtsx" -ProjectName "TestProject" - FolderName "TestFolder"

    
    #>

    Param(  [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]
            [string]$SqlServerName,
        
            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]
            [string]$IspacPath,
        
            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]
            [string]$ProjectName,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$true)]
            [string]$FolderName
    )

    Write-Host ""
    Write-Host "Deploying SSIS package ..." -ForegroundColor Cyan

    # If SSISDB does not exist a password is needed to create a new one. Provide a secure password here.
    $ssisDbPwd = "SuperSecretPassword#123"

    # Load the IntegrationServices Assembly (Needs to be installed on the system) 
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;

    # Store the IntegrationServices Assembly namespace to avoid typing it every time
    $isNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

    Write-Host "Connecting to server ..."

    # Create a connection to the server
    $sqlConnectionString = "Data Source=" + $SqlServerName + ";Initial Catalog=master;Integrated Security=SSPI;"
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString

    # Create the Integration Services object
    $integrationServices = New-Object $isNamespace".IntegrationServices" $sqlConnection

    $catalog = $integrationServices.Catalogs["SSISDB"]

    # Create new SSISDB if it does not exist.
    if (!$catalog) 
    { 
        Create a new SSISDb if not exists
        Write-Host "Creating new SSISDB ..."
        
        $catalog = New-Object $isNamespace".Catalog" ($integrationServices, "SSISDB", $ssisDbPwd)
        $catalog.Create()
        $catalog = $integrationServices.Catalogs["SSISDB"] 
    }

    Write-Host "Creating Folder '$($FolderName)' ..."

    # Create a new folder
    $folder = New-Object $isNamespace".CatalogFolder" ($catalog, $FolderName, "Folder description")
    $folder.Create()

    Write-Host "Deploying '$($ProjectName)' project ..."

    # Read the project file, and deploy it to the folder
    [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($IspacPath)
    $folder.DeployProject($ProjectName, $projectFile)

    Write-Host "All done."
}
