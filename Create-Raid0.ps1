Function Create-Raid0
{
    <#

        .SYNOPSIS

        Create a raid 0 disk array..



        .DESCRIPTION

        This function selects all available disk and creates a raid 0 disk array out of them.
        At least two hard disks are neccessary to create a raid 0 disk array.
        The disk array is formated with NTFS and a drive letter is automatically assigned.


        .EXAMPLE 

        Create-Raid0

    #>

    $PhysicalDisks =  Get-PhysicalDisk -CanPool $True

    if($PhysicalDisks)
    {
	    New-StoragePool -FriendlyName "Pool1" -StorageSubSystemFriendlyName "storage spaces*" -PhysicalDisks $PhysicalDisks |
	    New-VirtualDisk -FriendlyName "DataDisk" -UseMaximumSize -NumberOfColumns $PhysicalDisks.Count -ResiliencySettingName "Simple" -ProvisioningType Fixed -Interleave 65536 |
	    Initialize-Disk -Confirm:$false -PassThru |
	    New-Partition -AssignDriveLetter -UseMaximumSize |
	    Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -AllocationUnitSize 64KB -Confirm:$false
    }
}
