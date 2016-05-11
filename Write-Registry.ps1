Function Write-Registry 
{
    <#

    .SYNOPSIS

    Write values to the registry



    .DESCRIPTION

    This function writes values to the registry. As Set-ItemProperty can access HKEY_CURRENT_USER and HKEY_LOCAL_MACHINE only, this function uses WMI registry provider for
    full access to the registry.
    When the registry key does not exists, it will be created.

    As all registry hives, despite HKEY_CURRENT_USER require elevated priviliges, the function checks the current security principals and and elevates the security context if its neccessary. 


    .PARAMETER Hive 

    Registry hive name. Selectable values are:

    HKCR = HKEY_CLASSES_ROOT 
    HKCU = HKEY_CURRENT_USER 
    HKLM = HKEY_LOCAL_MACHINE 
    HKUS = HKEY_USERS 
    HKCC = HKEY_CURRENT_CONFIG


    .PARAMETER Key
    
    Name of the regitsry key to write, e.g: "SOFTWARE\Microsoft\Internet Explorer\Settings" 


    .PARAMETER RegKeyType 

    Type of registry key to write. Selectable values are:

    REG_SZ         = String (String)
    REG_BINARY     = Binary (Byte[])
    REG_EXPAND_SZ  = ExpandString (String)
    REG_DWORD      = DWord (Int32)
    REG_QWORD      = QWord (Int64)
    REG_MULTI_SZ   = MultiString (String[])


    .PARAMETER ValueName

    Name of the value to be written. Leave out to set default.


    .PARAMETER Value

    The value to be written.



    .EXAMPLE 

    Write-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\Document Windows" -RegKeyType REG_BINARY -ValueName "height" -Value @(72,101,108,108,111,32,87,111,114,108,100)
    Write-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\GPU" -RegKeyType REG_DWORD -ValueName "Revision" -Value 12345
    Write-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MMC\SnapIns\{5ADF5BF6-E452-11D1-945A-00C04FB984F9}" -RegKeyType REG_EXPAND_SZ -ValueName "NameStringIndirect" -Value "test1 test2 test3"
    Write-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MTF" -RegKeyType REG_MULTI_SZ -ValueName "ValuSet" -Value @("value1", "value2", "value3")
    Write-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MTF\2" -RegKeyType REG_QWORD -ValueName "DocCount" -Value 122423421353454354353243253
    Write-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\Settings" -RegKeyType REG_SZ -ValueName "Text Color" -Value "Black"
 


    .LINK
    
    https://msdn.microsoft.com/de-de/library/aa393664(v=vs.85).aspx 

    #>

    [CmdLetBinding()]
    Param(  
            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [ValidateSet("HKCR", "HKCU", "HKLM", "HKUS" , "HKCC")]
            [string]$Hive,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [string]$Key,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [ValidateSet("REG_SZ", "REG_BINARY", "REG_EXPAND_SZ", "REG_DWORD" , "REG_QWORD", "REG_MULTI_SZ")]
            [string]$RegKeyType,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$False)]
            [string]$ValueName,

            [ValidateNotNullOrEmpty()]
            [Parameter(Mandatory=$True)]
            [string]$Value
        )

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
    { 
        $process = Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -PassThru -Wait
        return $process.ExitCode
    }

    $HKCR = 2147483648 #HKEY_CLASSES_ROOT 
    $HKCU = 2147483649 #HKEY_CURRENT_USER 
    $HKLM = 2147483650 #HKEY_LOCAL_MACHINE 
    $HKUS = 2147483651 #HKEY_USERS 
    $HKCC = 2147483653 #HKEY_CURRENT_CONFIG

    $Reg = [wmiclass]‘\\.\root\default:StdRegprov’

    Switch($Hive)
    {
        "HKCR" { $RegHive = $HKCR }
        "HKCU" { $RegHive = $HKCU }
        "HKLM" { $RegHive = $HKLM }
        "HKUS" { $RegHive = $HKUS }
        "HKCC" { $RegHive = $HKCC }
    }

    if ($Reg.EnumKey($RegHive, $key).ReturnValue -ne 0)
    {
        $Reg.CreateKey($RegHive, $key) | Out-Null
    }

    Switch($RegKeyType)
    {
        "REG_SZ" {
            $RegObj = $Reg.SetStringValue($RegHive, $Key, $ValueName, $Value)             
            break 
        }
        "REG_BINARY" {
            $RegObj = $Reg.SetBinaryValue($RegHive, $Key, $ValueName, $Value)               
            break
        }
        "REG_EXPAND_SZ" {
            $RegObj = $Reg.SetExpandedStringValue($RegHive, $Key, $ValueName, $Value)
            break
        }
        "REG_DWORD" {
            $RegObj = $Reg.SetDWORDValue($RegHive, $Key, $ValueName, $Value)               
            break
        }
        "REG_QWORD" {
            $RegObj = $Reg.SetQWORDValue($RegHive, $Key, $ValueName, $Value)
            break
        }
        "REG_MULTI_SZ" {
            $RegObj = $Reg.SetMultiStringValue($RegHive, $Key, $ValueName, $Value)
            break
        }
    }

    return $RegObj.ReturnValue
}
