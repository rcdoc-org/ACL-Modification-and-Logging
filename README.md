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
- backupFolder
    - Type: [String]
    - Purpose:
    Used for declaring the path for the folder to handle the .xml files created to have a record of the previous ACL permissions. This can be used to replace ACL permissions if needed in the future.
- logFile
    - Type: [String]
    - Purpose:
    Used for declaring the path for the log file which should be a ".csv". This will hold the log of all changes made on all folders including if no changes were made.