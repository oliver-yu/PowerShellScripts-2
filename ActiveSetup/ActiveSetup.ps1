<#

    .SYNOPSIS

    Automated active setup handling.



    .DESCRIPTION


    This scripts automates active setup handling during the installation, or uninstallation of a package.
    In times of multi user environments, it is neccessary to build packages that include mechanics to perform post installations for users how are not currently logged on to computers
    running installations. Even so more than one user can be logged in at the same time, but only one user can perform an installation.
    
    But how can you performe installation actions for currently logged in users, that are not running the installation by them self?
    
    The answer ist active setup. For more information about active setup use the link below in the "notes" section. 
 
    For installing/uninstalling files, or setting/removing registry keys for other users, currently logged in during installation, create your scripts, 
    doing all the needed actions and compile them as exe-files. Anme them "Install.exe" and "Unistall.exe".
    Place Install.exe/Uninstall.exe in active setup folder. Active Setup folder must be located under Common Program Files (x86) directory.
    Username and SID will be passed on the command line for use in your script.

    For performing actions, for users not logged in during installation, place your scripts in the same directory, naming them: "ActiveSetupInstall.EXE" and "ActiveSetupUninstall.EXE".
    Use current user context in this script.

    Include the example command line calls below in your package.
    All neccessarry registry keys for active steup will be created and updated automatically. 



    .PARAMETER GUID 

    Pakage GUID.



    .PARAMETER Vendor 

    Pakage Vendor.



    .PARAMETER ProductName 

    Pakage product name.



    .PARAMETER Version 

    Pakage version.



    .PARAMETER Folder 

    Active setup folder, containing all active setup files. Located under Common Programm Files (x86).



    .PARAMETER Method 

    Active setup method. Valid options: "install","install-nologonuser", "uninstall","uninstall-nologonuser".



    .EXAMPLE 

    ActiveSetup-LocalMachine - GUID $GUID -Vendor "Microsoft" -ProductName ".Net Framework" -Version "x.x.xxxx" -Folder "ActiveSetupFolder" -Method "install"
    
    ActiveSetup-LocalMachine - GUID $GUID -Vendor "Microsoft" -ProductName ".Net Framework" -Version "x.x.xxxx" -Folder "ActiveSetupFolder" -Method "uninstall" 



    .NOTES

    Link: https://blogs.msdn.microsoft.com/aruns_blog/2011/06/20/active-setup-registry-key-what-it-is-and-how-to-create-in-the-package-using-admin-studio-install-shield/

#>

param( [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]   
        [string]$GUID,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [string]$Vendor,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [string]$ProductName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [string]$Version,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [string]$Folder,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [string]$Method
)

Function Normalize-SID 
{
    <#

        .SYNOPSIS

        Normalizes given SID.



        .DESCRIPTION


        Removes leading and trailing brakets of a given SID.



        .EXAMPLE 

        Normalize-SID

    
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]  
            [string]$SID
    )
    
    if ($SID.StartsWith("{")) 
    {
        $SID = $SID.TrimStart("{")
    }
    
    if ($SID.EndsWith("}")) 
    {
        $SID = $SID.TrimEnd("}")
    }
    
    return $SID
}

Function Normalize-GUID 
{   
    <#

        .SYNOPSIS

        Normalizes given GUID.



        .DESCRIPTION


        Adds missing leading and trailing brakets to a given GUI.



        .EXAMPLE 

        Normalize-GUID

    
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$GUID
    )
    
    if (!$GUID.StartsWith("{")) 
    {
        $GUID = "{" + $GUID
    }
    
    if (!$GUID.EndsWith("}")) 
    {
        $GUID = $GUID + "}"
    }

    return $GUID
}

Function Normalize-Version 
{
    <#

        .SYNOPSIS

        Normalizes given version.



        .DESCRIPTION


        Replaces dot seperated version numbers with comma separated.



        .EXAMPLE 

        Normalize-Version

    
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$Version
    )
    
    $Version = $Version.Replace(".", ",")
    
    return $Version
}

Function Get-LoggedOnUsersSID 
{
    <#

        .SYNOPSIS

        Retrieves logged on users names and SIDs.



        .DESCRIPTION


        This functions retrieves all currently logged on users on a computer an returns thier names and SIDs.



        .EXAMPLE 

        Get-LoggedOnUsersSID



        .NOTES

        Logon type 2 and 10 checking for local and RDP connections.
   
    #> 

    $regexDomain = '.+Domain="(.+)",Name="(.+)"$'
    $regexLogin = '.+LogonId="(\d+)"$'
    $logonSessions = @(Get-WmiObject Win32_LogonSession | Where-Object -FilterScript { $_.LogonType -eq '2' -or $_.LogonType -eq '10' })
    $logonUsers = @(Get-WmiObject Win32_LoggedOnUser)
    $sessionUser = @{}
    $arrNames = @()

    $logonUsers | % {
        $_.antecedent -match $regexDomain > $nul
        $username = $matches[1] + "\" + $matches[2]
        $_.dependent -match $regexLogin > $nul
        $session = $matches[1]
        $sessionUser[$session] += $username  
    }

    $logonSessions | % {
        $name = $sessionUser[$_.logonid]
        
        if ($arrNames -notcontains $name) 
        {
            $arrNames += $name
            $SID = Get-WmiObject Win32_UserAccount | Where-Object -FilterScript { $_.Caption -eq $name }
            
            if ($SID) 
            {
                $loggedOnUser = New-Object -TypeName PsObject
                $loggedOnUser | Add-Member -MemberType NoteProperty -Name "UserName" -Value $sessionUser[$_.logonid]
                $loggedOnUser | Add-Member -MemberType NoteProperty -Name "SID" -Value $(Normalize-SID -SID $SID.SID) 
                $loggedOnUser
            }
        }
    }
}

Function Create-Keys 
{
    <#

        .SYNOPSIS

        Create Active Setup registry keys.



        .DESCRIPTION


        Create Active Setup registry keys under HKEY_LOCAL_MACHINE hive on local machine.



        .EXAMPLE 

        Create-Keys
   
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $RegistryPath,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$Vendor,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$ProductName,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$Version,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            [string]$RegType
    )

    New-ItemProperty HKLM:\$($RegistryPath) -Name "(Default)" -Value "$Vendor $ProductName"
    New-ItemProperty HKLM:\$($RegistryPath) -Name "ComponentID" -PropertyType String -Value "$Vendor $ProductName"
    New-ItemProperty HKLM:\$($RegistryPath) -Name "IsInstalled" -PropertyType Dword -Value "1"
    New-ItemProperty HKLM:\$($RegistryPath) -Name "DontAsk" -PropertyType Dword -Value "2"
    New-ItemProperty HKLM:\$($RegistryPath) -Name "Locale" -PropertyType String -Value $RegType
    New-ItemProperty HKLM:\$($RegistryPath) -Name "Version" -PropertyType String -Value (Normalize-Version -Version $Version)
}

Function ActiveSetup-CurrentUser 
{
    <#

        .SYNOPSIS

        Current user active setup handling.



        .DESCRIPTION


        Performs active setup actions for users not logged in during installation of the package.
        Create your scripts, performing all the acrtions needed after the installation of the package and compile them as exe-files.
        Name them "ActiveSetupInstall.EXE" or "ActiveSetupUninstall.EXE".
        Place both in active setup folder. Active Setup folder must be located in Common Program Files (x86) directory.


        .PARAMETER GUID 

        Pakage GUID passed from active setup package GUID in HKLM.



        .PARAMETER Folder 

        Active setup folder, containing all active setup files. Located under Common Programm Files (x86).



        .PARAMETER Method 

        Active setup method. Valid options: "active_setup_install" and "active_setup_uninstall".



        .EXAMPLE 

        ActiveSetup-CurrentUser - GUID $GUID -Folder "ActiveSetupFolder" -Method $Method

    
    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $GUID,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Folder,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Method
    )

    $ActiveSetupFolder = "$(${env:CommonProgramFiles(x86)})\$($Folder)"
    $RegPath = "Software\Microsoft\Active Setup\Installed Components\$(Normalize-GUID -GUID $GUID)"
    $ActiveSetupFile = "$($ActiveSetupFolder)\ActiveSetupUninstall.EXE"

    if ($Method -eq "active_setup_install")
    { 
        $ActiveSetupFile = "$($ActiveSetupFolder)\ActiveSetupInstall.EXE"
        $RegPath += "_uninstall"
    }

    if ((Test-Path -Path $ActiveSetupFile -PathType Leaf)) 
    {
        Start-Process $ActiveSetupFile -WindowStyle Hidden
    }

    if ((Test-Path "HKCU:\$($RegPath)")) 
    {
        Remove-Item "HKCU:\$($RegPath)"
    }

}

Function ActiveSetup-LocalMachine 
{
    <#

        .SYNOPSIS

        Local machine active setup handling.



        .DESCRIPTION


        This function automates all active setup actions during package installation. 
        For installing/uninstalling files, or setting/removing registry keys for users, currently logged in during installation, create your scripts, doing all the needed actions and compile them as exe-files.
        Place Install.exe/Uninstall.exe in active setup folder. Active Setup folder must be located in Common Program Files (x86) directory.
        Username and SID will be passed on the command line for use in your script.

        For performing actions, for users not logged in during installation, place your scripts in the same directory, naming them: "ActiveSetupInstall.EXE" and "ActiveSetupUninstall.EXE".



        .PARAMETER GUID 

        Pakage GUID.



        .PARAMETER Vendor 

        Pakage Vendor.



        .PARAMETER ProductName 

        Pakage product name.



        .PARAMETER Version 

        Pakage version.



        .PARAMETER Folder 

        Active setup folder, containing all active setup files. Located under Common Programm Files (x86).



        .PARAMETER Method 

        Active setup method. Valid options: "install","install-nologonuser", "uninstall","uninstall-nologonuser".



        .EXAMPLE 

        ActiveSetup-LocalMachine - GUID $GUID -Vendor "Microsoft" -ProductName ".Net Framework" -Version "x.x.xxxx" -Folder "ActiveSetupFolder" -Method "install" 

    #>

    param(  [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $GUID,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Vendor,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $ProductName,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Version,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Folder,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()] 
            $Method
    )

    $GUID = Normalize-GUID -GUID $GUID
    $Version = Normalize-Version -Version $Version
    $ActiveSetupFolder = "$(${env:CommonProgramFiles(x86)})\$($Folder)"
    $RegPath = "Software\Microsoft\Active Setup\Installed Components\$($GUID)"

    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") 
    {
        $RegType = "x64"
    } 
    else 
    {
        $RegType = "x32"
    }  

    if ($Method -eq "install" -or $Method -eq "install-nologonuser") 
    {
        if ((Test-Path -Path HKLM:\$($RegPath)_uninstall)) 
        {
            Remove-Item -Path HKLM:\$($RegPath)_uninstall
        }

        New-Item -Path HKLM:\$($RegPath) -Force
        New-ItemProperty HKLM:\$($RegPath) -Name "StubPath" -PropertyType String -Value """$($ActiveSetupFolder)\ActiveSetup.exe"" ""$($GUID)""  ""$($Vendor)"" ""$($ProductName)"" ""$($Version)"" ""$($Folder)"" ""active_setup_install"""
        Create-Keys -RegistryPath $RegPath -Vendor $Vendor -ProductName $ProductName -Version $Version -RegType $RegType    

        if ($Method -eq "install") 
        {
            $users = Get-LoggedOnUsersSID
            
            if ($users) 
            {
                New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
                
                foreach ($user in $users) 
                {
                    if ((Test-Path -Path HKU:\$($user.SID)\$($RegPath)_uninstall)) 
                    {
                        Remove-Item -Path HKU:\$($user.SID)\$($RegPath)_uninstall
                    }

                    New-Item -Path HKU:\$($user.SID)\$($RegPath) -Force
                    New-ItemProperty HKU:\$($user.SID)\$($RegPath) -Name "Locale" -PropertyType String -Value $RegType
                    New-ItemProperty HKU:\$($user.SID)\$($RegPath) -Name "Version" -PropertyType String -Value $Version

                    if ((Test-Path -Path "$($ActiveSetupFolder)\Install.EXE" -PathType Leaf)) 
                    {
                        Start-Process -FilePath "$($ActiveSetupFolder)\Install.EXE" -ArgumentList $user.Name, $user.SID -WindowStyle Hidden
                    }
                }
            }
        }           

    } 
    elseif ($Method -eq "uninstall" -or $Method -eq "uninstall-nologonuser") 
    {
        if ((Test-Path -Path HKLM:\$($RegPath))) 
        {
            Remove-Item -Path HKLM:\$($RegPath)
        }

        $UninstallRegPath = "$($RegPath)_uninstall"
        New-Item -Path HKLM:\$($UninstallRegPath) -Force
        New-ItemProperty -Path HKLM:\$($UninstallRegPath) -Name "StubPath" -PropertyType String -Value """$($ActiveSetupFolder)\ActiveSetup.exe"" ""$($GUID)""  ""$($Vendor)"" ""$($ProductName)"" ""$($Version)"" ""$($Folder)"" ""active_setup_uninstall"""
        Create-Keys -RegistryPath $UninstallRegPath -Vendor $Vendor -ProductName $ProductName -Version $Version -RegType $RegType 

        if ($Method -eq "uninstall") 
        {
            $users = Get-LoggedOnUsersSID
            
            if ($users) 
            {
                New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
                
                foreach ($user in $users) 
                {
                    if ((Test-Path -Path HKU:\$($user.SID)\$($RegPath))) 
                    {
                        Remove-Item -Path HKU:\$($user.SID)\$($RegPath)
                    }

                    New-Item -Path HKU:\$($user.SID)\$($UninstallRegPath) -Force
                    New-ItemProperty HKU:\$($user.SID)\$($UninstallRegPath) -Name "Locale" -PropertyType String -Value $RegType
                    New-ItemProperty HKU:\$($user.SID)\$($UninstallRegPath) -Name "Version" -PropertyType String -Value $Version

                    if ((Test-Path -Path "$($ActiveSetupFolder)\Uninstall.EXE" -PathType Leaf)) 
                    {
                        Start-Process -FilePath "$($ActiveSetupFolder)\Uninstall.EXE" -ArgumentList $user.Name, $user.SID -WindowStyle Hidden
                    }
                }
            }
        }
    }
}


if ($Method.Contains("active_setup")) 
{
    ActiveSetup-CurrentUser -GUID $GUID -Folder $Folder -Method $Method
} 
else 
{
    ActiveSetup-LocalMachine -GUID $GUID -Folder $Folder -Method $Method
}
