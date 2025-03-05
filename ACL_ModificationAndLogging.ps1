 # Define the root folder and allowed group.
$rootPath = "<rootPathGoesHere>"          
$allowedGroups = @("<Group1>","<Group2>","<etc.>")

#Set the rights to be removed
$removeRights = [System.Security.AccessControl.FileSystemRights]::Delete -bor [System.Security.AccessControl.FileSystemRights]::DeleteSubdirectoriesAndFiles

#Set backup locations
$backupFolder = "<backupFolderPathGoesHere>"
$logFile = "<logFilePathGoesHere>"

#Functions

###############################################################################
# FUNCTION: Check_And_Create_BackupFolder
###############################################################################
function Check_And_Create_BackupFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BackupFolder
    )

    if (!(Test-Path -Path $BackupFolder)) {
        New-Item -Path $BackupFolder -ItemType Directory
    }
}

###############################################################################
# FUNCTION: Check_And_Create_LogFile
###############################################################################
function Check_And_Create_LogFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    if (!(Test-Path $LogFile)) {
        "Folder,Identity,OriginalRights,ModifiedRights,Action" | Out-File -FilePath $LogFile -Encoding UTF8
    }
}

###############################################################################
# FUNCTION: Capture_All_FilesFolders
###############################################################################
function Capture_All_FilesFolders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RootPath
    )

    $folders = Get-ChildItem -Path $RootPath -Directory -Recurse
    $folders += Get-Item -Path $RootPath

    return $folders
}

###############################################################################
# FUNCTION: Processing_FileFolderChanges
###############################################################################
function Processing_FileFolder_Changes {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$Folders,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedGroups,
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemRights]$RemoveRights,
        [Parameter(Mandatory = $true)]
        [string]$LogFile,
        [Parameter(Mandatory = $true)]
        [string]$BackupFolder
    )

    foreach ($folder in $Folders) {
        Write-Host "Processing folder: $($folder.FullName)"
        
        #Capture Current ACL Rule
        $acl = Retrieve_Current_ACL -Folder $folder

        #Backup Current ACL Rule
        Backup_Current_ACL -Folder $folder -Acl $acl -BackupFolder $BackupFolder

        #Process access rules one by one
        $modified = Process_Access_Rules -Folder $folder -Acl $acl -AllowedGroups $AllowedGroups -RemoveRights $RemoveRights -LogFile $LogFile

        if($modified) {
            Update_ACLS -Folder $folder -Acl $acl
        }
        else {
            Log_None_Modified -Folder $folder -LogFile $LogFile
        }

    }
}

###############################################################################
# FUNCTION: Retrieve_Current_ACL
###############################################################################
function Retrieve_Current_ACL {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder
    )
    return Get-Acl -Path $Folder.FullName
}

###############################################################################
# FUNCTION: Backup_Current_ACL
###############################################################################
function Backup_Current_ACL {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)]
        $Acl,
        [Parameter(Mandatory = $true)]
        [string]$BackupFolder
    )
    $safeName = $Folder.FullName -replace "[:\\]","_"
    $backupFile = Join-Path $BackupFolder ($safeName + ".xml")
    $Acl | Export-Clixml -Path $backupFile
}

###############################################################################
# FUNCTION: Process_Access_Rules
###############################################################################
function Process_Access_Rules {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)]
        $Acl,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedGroups,
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemRights]$RemoveRights,
        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )
    $modified = $false

    foreach ($access in $Acl.Access) {
        # Skip if the ACE is for one of the allowed groups.
        if (Check_For_Allowed_Groups -Access $access -AllowedGroups $AllowedGroups) {
            continue
        }
        # Check if the ACE includes rights we need to remove.
        if (Check_For_Removed_Rights -Access $access -RemoveRights $RemoveRights) {
            $modified = $true
            $originalRights = $access.FileSystemRights
            $newRights = Calculate_NewRights -Access $access -RemoveRights $RemoveRights

            # Remove the current rule and add the updated one.
            $Acl.RemoveAccessRule($access)
            $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $access.IdentityReference,
                $newRights,
                $access.InheritanceFlags,
                $access.PropagationFlags,
                $access.AccessControlType
            )
            $Acl.AddAccessRule($newRule)
            
            Write-Host "Updated ACL for $($access.IdentityReference) on $($Folder.FullName)"
            Log_To_CSV -Folder $Folder -Identity $access.IdentityReference -OriginalRights $originalRights `
                       -NewRights $newRights -LogFile $LogFile -Action "Modified"
        }
    }
    return $modified
}

###############################################################################
# FUNCTION: Check_For_Allowed_Groups
###############################################################################
function Check_For_Allowed_Groups {
    param(
        [Parameter(Mandatory = $true)]
        $Access,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedGroups
    )
    return $AllowedGroups -contains $Access.IdentityReference.Value
}

###############################################################################
# FUNCTION: Check_For_Removed_Rights
###############################################################################
function Check_For_Removed_Rights {
    param(
        [Parameter(Mandatory = $true)]
        $Access,
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemRights]$RemoveRights
    )
    return ( ($Access.FileSystemRights -band $RemoveRights) -ne 0 )
}

#calculate new rights by removing deleate rights.
function Calculate_NewRights {
    param(
        [Parameter(Mandatory = $true)]
        $Access,
        [Parameter(Mandatory = $true)]
        [System.Security.AccessControl.FileSystemRights]$RemoveRights
    )
    return $Access.FileSystemRights -band (-bnot $RemoveRights)
}

###############################################################################
# FUNCTION: Log_To_CSV
###############################################################################
function Log_To_CSV {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)]
        $Identity,
        [Parameter(Mandatory = $true)]
        $OriginalRights,
        [Parameter(Mandatory = $true)]
        $NewRights,
        [Parameter(Mandatory = $true)]
        [string]$LogFile,
        [Parameter(Mandatory = $true)]
        [string]$Action
    )
    $logEntry = "$($Folder.FullName),$($Identity),$OriginalRights,$NewRights,$Action"
    $logEntry | Out-File -Append -FilePath $LogFile -Encoding UTF8
}

###############################################################################
# FUNCTION: Update_ACLS
###############################################################################
function Update_ACLS {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)]
        $Acl
    )
    try {
        Set-Acl -Path $Folder.FullName -AclObject $Acl
        Write-Host "ACL updated for folder: $($Folder.FullName)"
    }
    catch {
        Write-Warning "Failed to update ACL for folder: $($Folder.FullName). Error: $_"
    }
}

###############################################################################
# FUNCTION: Log_None_Modified
###############################################################################
function Log_None_Modified {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )
    $logEntry = "$($Folder.FullName),,,No changes made"
    $logEntry | Out-File -Append -FilePath $LogFile -Encoding UTF8
}


Check_And_Create_BackupFolder -BackupFolder $backupFolder
Check_And_Create_LogFile -LogFile $logFile

$folders = Capture_All_FilesFolders -RootPath $rootPath
 
Processing_FileFolder_Changes -Folders $folders -AllowedGroups $allowedGroups -RemoveRights $removeRights -LogFile $logFile -BackupFolder $backupFolder