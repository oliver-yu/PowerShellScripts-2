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
