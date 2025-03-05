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
    - This function takes in all the needed global variables It can handle both remove rights and add rights at the same time but runs them one after the other on each file in succession. This function then calls all other functions except for the Check_And_Create_BackupFolder, Check_And_Create_LogFile, and Capture_All_FilesFolders which run before it. This is similar to the main function of a program when called.
    
- Retrieve_Current_ACL
    - This function takes in an individual folder from the folders array that's passed via the function, "Processing_FileFolder_Changes". It then returns the ACL's on the item via the built in function, "Get-ACL".

- Backup_Current_ACL
    - This function takes in an individual folder, the current ACL permissions on the item, and the Backup Folder path. It then uses a simple regular expression to replace invalid file names. Creates a backup file path using the built in function, "Join-Path". And lastly uses the built in function, "Export-Clixml" to export the current ACL to this new .xml file.

- Process_Access_Rules
- Check_For_Allowed_Groups
    - This function takes in the current ACL Access item and the global variable AllowedGroups and checks if the item's Identity Reference Value matches one of the user groups in the allowed groups variable. And then returns the result of that check.

- Check_For_Removed_Rights
    - This function takes in the current access item and the global variable remove rights. It does a bit operation to check if the removed right exists on the existing rights and returns an expression comparing the result to if it's not equal to 0. 

- Check_For_Add_Rights
    - This function takes in the current access item and the global variable remove rights. It does a bit operation to check if the removed right exists on the existing rights and returns an expression comparing the result to if it is equal to 0. 

- Calculate_NewRights
    - This function is designed around the principle that either the access item and removed items is sent to it or the access item and add items is sent to it. Based on which global variable came into the function determines the expression used via bit operations. This will either remove the right using both -band and -bnot or add the right using -bor.

- Log_To_CSV
    - This function is designed to complete the simple task of loggin the changes made. It takes in multiple variables for logging and crates a line item variable. That line item variable is then piped into the built in function, "Out-File" via an append for keeping track of the log of changes.

- Update_ACLS
    - This function applies the actual change to the folder/item ACLs. It does this by first taking in the folder item, and new acl that was generated during the "Process_Access_Rules" function. It has a try - catch where it tries to use the built in function, "Set-ACL" to set the file/folder with the new ACL object. If successful it prints the terminal that the folder/item in question was updated. If it fails it catches the error and prints a warning explaining what occurred and showing the error afterwords from the terminal. Then it safely returns the "Process_Access_Rules" function.

- Log_None_Modified
    - This function is only called when no actions are made on the ACL in question and logs the csv file declared as a global variable that no changes were made to the file/folder in question.

## Running Details: