Function Read-Registry {

    <#

    .SYNOPSIS

    Read values form the registry



    .DESCRIPTION

    This function read values from the registry. As Get-ItemProperty can access HKEY_CURRENT_USER and HKEY_LOCAL_MACHINE only, this function uses WMI registry provider for
    full access to the registry.




    .PARAMETER Hive 

    Registry hive name. Selectable values are:

    HKCR = HKEY_CLASSES_ROOT 
    HKCU = HKEY_CURRENT_USER 
    HKLM = HKEY_LOCAL_MACHINE 
    HKUS = HKEY_USERS 
    HKCC = HKEY_CURRENT_CONFIG


    .PARAMETER Key
    
    Name of the regitsry key to read, e.g: "SOFTWARE\Microsoft\Internet Explorer\Settings" 


    .PARAMETER RegKeyType 

    Type of registry key to read. Selectable values are:

    REG_SZ         = String (String)
    REG_BINARY     = Binary (Byte[])
    REG_EXPAND_SZ  = ExpandString (String)
    REG_DWORD      = DWord (Int32)
    REG_QWORD      = QWord (Int64)
    REG_MULTI_SZ   = MultiString (String[])


    .PARAMETER ValueName

    Name of the value to read. Leave out to read default value.



    .EXAMPLE 

    Read-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\Document Windows" -RegKeyType REG_BINARY -ValueName "height"
    Read-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\GPU" -RegKeyType REG_DWORD -ValueName "Revision"
    Read-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MMC\SnapIns\{5ADF5BF6-E452-11D1-945A-00C04FB984F9}" -RegKeyType REG_EXPAND_SZ -ValueName "NameStringIndirect"
    Read-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MTF" -RegKeyType REG_MULTI_SZ -ValueName "ValuSet"
    Read-Registry -Hive HKLM -Key "SOFTWARE\Microsoft\MTF\2" -RegKeyType REG_QWORD -ValueName "DocCount"
    Read-Registry -Hive HKCU -Key "SOFTWARE\Microsoft\Internet Explorer\Settings" -RegKeyType REG_SZ -ValueName "Text Color"



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
            [string]$ValueName
        )

    $HKCR = 2147483648 #HKEY_CLASSES_ROOT 
    $HKCU = 2147483649 #HKEY_CURRENT_USER 
    $HKLM = 2147483650 #HKEY_LOCAL_MACHINE 
    $HKUS = 2147483651 #HKEY_USERS 
    $HKCC = 2147483653 #HKEY_CURRENT_CONFIG

    $reg = [wmiclass]‘\\.\root\default:StdRegprov’

    Switch($Hive)
    {
        "HKCR" { $RegHive = $HKCR }
        "HKCU" { $RegHive = $HKCU }
        "HKLM" { $RegHive = $HKLM }
        "HKUS" { $RegHive = $HKUS }
        "HKCC" { $RegHive = $HKCC }
    }

    Switch($RegKeyType)
    {
        "REG_SZ" {
            $RegObj = $reg.GetStringValue($RegHive, $Key, $ValueName)
            break 
        }
        "REG_BINARY" {
            $RegObj = $reg.GetBinaryValue($RegHive, $Key, $ValueName)
            break
        }
        "REG_EXPAND_SZ" {
            $RegObj = $reg.GetExpandedStringValue($RegHive, $Key, $ValueName)
            break
        }
        "REG_DWORD" {
            $RegObj = $reg.GetDWORDValue($RegHive, $Key, $ValueName)
            break
        }
        "REG_QWORD" {
            $RegObj = $reg.GetQWORDValue($RegHive, $Key, $ValueName)
            break
        }
        "REG_MULTI_SZ" {
            $RegObj = $reg.GetMultiStringValue($RegHive, $Key, $ValueName)
            break
        }
    }

    If ($RegObj.ReturnValue -eq 0)
    {
        if ($RegKeyType -eq "REG_BINARY" -or $RegKeyType -eq "REG_DWORD" -or $RegKeyType -eq "REG_QWORD")
        {
            return $RegObj.uValue
        }
        elseif ($RegKeyType -eq "REG_SZ" -or $RegKeyType -eq "REG_EXPAND_SZ" -or "REG_MULTI_SZ")
        {
            return $RegObj.sValue
        }
    }
    else
    {
        throw "Could not read '$($Hive):\$($Key)\$($ValueName)'. Error code: $($RegObj.ReturnValue)"
    }
}
