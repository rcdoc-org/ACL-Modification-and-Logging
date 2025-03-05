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
    - This function takes in the root path given in the global variables and then captures all the files and folders into one array that's type [System.IO.DirectoryInfor[]] in the script. It then returns that array to the function, "Processing_FileFolder_Changes".

- Processing_FileFolder_Changes
- Retrieve_Current_ACL
    - This function takes in an individual folder from the folders array that's passed via the function, "Processing_FileFolder_Changes". It then returns the ACL's on the item via the built in function, "Get-ACL".

- Backup_Current_ACL
    - This function takes in an individual folder, the current ACL permissions on the item, and the Backup Folder path. It then uses a simple regular expression to replace invalid file names. Creates a backup file path using the built in function, "Join-Path". And lastly uses the built in function, "Export-Clixml" to export the current ACL to this new .xml file.

- Process_Access_Rules
- Check_For_Allowed_Groups
    - This function takes in the current ACL Access item and the global variable AllowedGroups and checks if the item's Identity Reference Value matches one of the user groups in the allowed groups variable. And then returns the result of that check.

- Check_For_Removed_Rights
    - This function takes in the current access item and the global variable remove rights. It does a bit operation to check if the removed right exists on the existing rights and returns an expression comparing the result to if its not equal to 0. 
    
- Check_For_Add_Rights
- Calculate_NewRights
- Log_To_CSV
- Update_ACLS
- Log_None_Modified

## Running Details: