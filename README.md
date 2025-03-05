# ACL-Modification-and-Logging
Used for automating the process for removing ACL permissions to all but a specific certain named groups. This is completely modularized in functions to allow for easy reuse of code in other projects.

## Global Variable Assignments
- rootPath
    - Type: [String]
    - Purpose:
        Used for declaring the location of the top most folder of the heir archy. It used used recursively so we do not need to know all the folders. It will only run this script against this folder contents and other folders contents contained in the root path.
- allowedGroups
    - Type: [Array[String]]
    - Purpose:
        Used for declaring user groups that should not be affected by this script. These user groups will be skipped when it comes time to use the function, "Process_Access_Rules".
- removeRights
    - Type: [System.Security.AccessControl.FileSystemRights]
    - Purpose:
    Used for declaring the ACLs we want to remove from users. Its only used by the function, "Process_Access_Rules".
- addRights
    - Type: [System.Security.AccessControl.FileSystemRights]
    - Purpose:
    Used for declaring the ACLs we want to add to users. Its only used by the function, "Process_Access_Rules".
- backupFolder
    - Type: [String]
    - Purpose:
    Used for declaring the path for the folder to handle the .xml files created to have a record of the previous ACL permissions. This can be used to replace ACL permissions if needed in the future.
- logFile
    - Type: [String]
    - Purpose:
    Used for declaring the path for the log file which should be a ".csv". This will hold the log of all changes made on all folders including if no changes were made.

## Functions
- Check_And_Create_BackupFolder
    - This function simply checks via the built in function, "Test-Path" to see if the $BackupFolder already exists, and if not, "!", it creates the folder using the built in function, "New-Item".

- Check_And_Create_LogFile
    - This function simply checks via the built in function, "Test-Path" to see if the $LogFile already exists, and if not, "!", it creates the log file using a string header that is piped to a built in function, "Out-File" to create the needed csv file.

- Capture_All_FilesFolders
- Processing_FileFolder_Changes
- Retrieve_Current_ACL
- Backup_Current_ACL
- Process_Access_Rules
- Check_For_Allowed_Groups
- Check_For_Removed_Rights
- Check_For_Add_Rights
- Calculate_NewRights
- Log_To_CSV
- Update_ACLS
- Log_None_Modified

## Running Details: