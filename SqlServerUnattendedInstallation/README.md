# SQL Server unattended installation 

This PowerShell script provides an unattended installation of almost any SQL Server edition. See description below for information how to use it and customize it to your needs.

To fully automate the SQL Server installation you need three things:

 - An SQL Server installation ISO-file
 - A configuration file (INI-file)
 - This short PowerShell script


##### Getting the resources for the SQL Server unattended installation

The ISO-file can be obtained from Microsoft . In this toturial I use the developer edition of SQL Server 2014, which I downloaded from the [MSDN](https://msdn.microsoft.com). You can use any edition of SQL Server, except the SQL Server Express Editions.

To get the configuration file needed for the SQL Server unattended installtion you just start the installation. Click thru the installation dialogs, which may differ depending on your edition of SQL Server, until you reach the feature selection.

![Feature Selection](https://ewjqoa.bl3301.livefilestore.com/y4m8DpS6fT5_ENPrAe1mXYghrHh14NYDec2fimPGphNXwCtVm-s7BXpiUg-eJ4_Q-zxpZo8dvhWeSfRwEo0sK7D3Ps-Sz-TQsW726zX0xw0RC9puQ3VbRAH4q14JKfn0X8NAxLi2bnsfNuyNG_-jNNyEExn9YLM4eYoNuFi9U-BJ4feC4a4_-XjLX4JHLXC6sONAA1Plq6aFYeXemmBfvs7sQ?width=1040&height=832&cropmode=none)

Now mark all the features you need for your SQL Server unattended installation. Afterwards click on "Next". When the confirmation dialog appears, do not click on "Install". You don't want to install SQL Server right now. The only thing you need here is the path to the "ConfigurationFile.ini".

![Confirmation Dialog](https://ewjkoa.bl3301.livefilestore.com/y4mdbKx-wJ6fUBiUL1rPxICwUsiYNdZkpUofHax8OPQxbXNvD35TbVhwHN10AhidzYULiADQWgiW8TkkIdSn3tHXggHibZnujSivj4adO--9wsj0OVmrwDJ4u_aLEJkSFqeFDBbAao8OZ6kssZXeernV2Cd4FG-wZddxvQrFFqmoIfgQwEBdtX134z_VUfDncqLgCQbN384ywVYXNoz56NLUw?width=1026&height=832&cropmode=none)

Copy the path and open it in file explorer.

![Explorer](https://ewjpoa.bl3301.livefilestore.com/y4mlvC1gZX-n4CmQ9GkfYKItEIj20uHlIbgXYjE3uv3z2FJoSFjZyYECDOClxor0LiMuQAP-_YJf06miIZF9iv3yFYe7tC36W6Fa6JXj6mXfUd1KqmmpVuTfNKfNPay8WrAdUvaJ_FLWMcP4YlgNIcndsq6tlHaMf07e7iq4N80XIh90FHXsL-GzxzHtKL9Lbh6RqM8AnR7tlkvM23X9-I59Q?width=873&height=566&cropmode=none)

Copy the file into a directory of your choise. It is a good advice to copy your ISO-file, your configuration file and the powershell script into the same directory. Afterwards cancel the installation.

Below you see the configuration file of my installation. The content of your configuration file may differ a little depending on the features and SQL Server version you choose for your SQL Server unattended installation, but it should look similar to the following one.


```ini
;SQL Server 2014 Configuration File
;https://msdn.microsoft.com/en-US/library/dd239405(v=sql.120).aspx
[OPTIONS]
ACTION="Install"
IACCEPTSQLSERVERLICENSETERMS="True"
ENU="True"
;UIMODE="Normal"
QUIET="True"
QUIETSIMPLE="False"
UpdateEnabled="True"
ERRORREPORTING="False"
USEMICROSOFTUPDATE="True"
FEATURES=SQLENGINE,REPLICATION,FULLTEXT,DQ,AS,RS,DQC,CONN,IS,BC,SDK,BOL,SSMS,ADV_SSMS,DREPLAY_CTLR,DREPLAY_CLT,MDS
UpdateSource="MU"
HELP="False"
INDICATEPROGRESS="True"
X86="False"
INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"
INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"
INSTANCENAME="MSSQLSERVER"
SQMREPORTING="False"
INSTANCEID="MSSQLSERVER"
;CTLRUSERS="BUILTINADMINISTRATORS"
CTLRSVCACCOUNT="NT Service\SQL Server Distributed Replay Controller"
CTLRSTARTUPTYPE="Manual"
CLTSVCACCOUNT="NT Service\SQL Server Distributed Replay Client"
CLTSTARTUPTYPE="Manual"
;CLTRESULTDIR="C:\Program Files (x86)\Microsoft SQL Server\DReplayClient\ResultDir"
;CLTWORKINGDIR="C:\Program Files (x86)\Microsoft SQL Server\DReplayClient\WorkingDir"
RSINSTALLMODE="DefaultNativeMode"
;INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
AGTSVCACCOUNT="NT Service\SQLSERVERAGENT"
AGTSVCSTARTUPTYPE="Manual"
ISSVCSTARTUPTYPE="Automatic"
ISSVCACCOUNT="NT Service\MsDtsServer120"
ASSVCACCOUNT="NT Service\MSSQLServerOLAPService"
ASSVCSTARTUPTYPE="Automatic"
ASCOLLATION="Latin1_General_CI_AS"
ASDATADIR="C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Data"
ASLOGDIR="C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Log"
ASBACKUPDIR="C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Backup"
ASTEMPDIR="C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Temp"
ASCONFIGDIR="C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Config"
ASPROVIDERMSOLAP="1"
ASSYSADMINACCOUNTS="<CURRENTUSER>"
ASSERVERMODE="MULTIDIMENSIONAL"
COMMFABRICPORT="0"
COMMFABRICNETWORKLEVEL="0"
COMMFABRICENCRYPTION="0"
MATRIXCMBRICKCOMMPORT="0"
SQLSVCSTARTUPTYPE="Automatic"
FILESTREAMLEVEL="0"
ENABLERANU="False"
SQLCOLLATION="Latin1_General_CI_AS"
SQLSVCACCOUNT="NT Service\MSSQLSERVER"
SQLSYSADMINACCOUNTS="<CURRENTUSER>"
TCPENABLED="0"
NPENABLED="0"
BROWSERSVCSTARTUPTYPE="Disabled"
RSSVCACCOUNT="NT Service\ReportServer"
RSSVCSTARTUPTYPE="Automatic"
FTSVCACCOUNT="NT Service\MSSQLFDLauncher"
```

Make sure that "IACCEPTSQLSERVERLICENSETERMS" (line 5) and "QUIET" (line 8) are set to "True", otherwise the installation will fail. If the lines are not present, add them. In line 7 the "UIMODE" is set. As this mode is not working with a silent installation, uncomment this line by placing a semicolon at the beginning or delete the line. Now take a look at lines 45 and 56. Normaly the values for "ASSYSADMINACOUNTS" and "SQLSYSADMINSACCOUNTS" contains the name of the user running the installation. As we don't know who will run the installation later, we can't leave it hard coded. So I added "<CURRENTUSER>" as a wildcard which will be replaced by the PowerShell script, I will provide later in this post, with the name of the user running the script.

Depending on the features you selected you may have to add the wildcard at more than these two positions. Replace every occurring of your current user acount in the configuration file with this wildcard.



##### Creating the script for the SQL Server unattended installation

All preparation is done now and we can take a look at the PowerShell script I created, to do all the magic we need for our SQL Server unattended installation.

```powershell
$Image = "<Full qualified path to SQL Server iso file>"
$IniPath = "$($PSScriptRoot)\ConfigurationFile.ini"
$Arguments = @("/ConfigurationFile=$iniPath")
$LogonUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$InstallState = (Get-WindowsOptionalFeature -online -featurename netfx3).State

# Install .Net framework 3.5 if not installed
if ($InstallState -ne "enabled") {
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All
} else {
    Write-Host ".Net Framework 3.5 already installed."
}

# Set current user as DB admin
$Content = [System.IO.File]::ReadAllText($IniPath) -ireplace '<CURRENTUSER>', $LogonUser
[System.IO.File]::WriteAllText($IniPath, $Content)

# Mount iso
$MoutVolume = Mount-DiskImage -ImagePath $Image -PassThru
$DriveLetter = ($MoutVolume | Get-Volume).DriveLetter
$InstallPath = $DriveLetter + ":\setup.exe"

# Run unattended installation
& $InstallPath $Arguments

# Dismount iso
Dismount-DiskImage -ImagePath $Image

# Remove current user from config file for reuse
$LogonUser = $LogonUser.Split('\')[0] + "\\" + $LogonUser.Split('\')[1]
$content = $Content -ireplace $LogonUser, '<CURRENTUSER>'
[System.IO.File]::WriteAllText($IniPath, $Content)
```

In the first two lines the path to the ISO-file and the path to the configuration file are set. If you copied your INI-file and this script into the same directory, you don't need to change the second line. You can even place your ISO-file on a network share and mount it from there. Doing so, you prevent copying a huge amount of data around.

Afterwards the name of the currently logged in user is set to a variable. Next the script checks for the .Net Framework 3.5 to be installed. This version of .Net Framework is neccessary for all actual available SQL Server versions. So it will be installed, if it's not present.

At line 15 the configuration file is parsed and the previously inserted "<CURRENTUSER>" wildcard is replaced with the name of the user running the script. So the user running the SQL Server unattended installation will be the administrator of the newly created SQL Server. Otherwise you would not have access to the SQL Server.
In the following lines the ISO-file is mounted and the installation is started. At the end the image is dismounted and the configuration file is reparsed and the changes are reverted. This is not really neccessary, I only added this part to make the file reusable.



And that's all. The script is ready to run the installation without any user input. As long as you have the appropriate configurtaion file, you can run  the installation of  any SQL Server version with this script.
