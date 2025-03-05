# ACL-Modification-and-Logging
Used for automating the process for removing ACL permissions to all but a specific certain named groups. This is completely modularized in functions to allow for easy reuse of code in other projects.

## Global Variable Assignments
- rootPath
    - Type: [String]
- allowedGroups
    - Type: [Array[String]]
- removeRights
    - Type: [System.Security.AccessControl.FileSystemRights]
- backupFolder
    - Type: [String]
- logFile
    - Type: [String]