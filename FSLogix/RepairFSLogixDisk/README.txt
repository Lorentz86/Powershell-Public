# RepairFSLogixDisk PowerShell Module

This PowerShell module is designed to detect and repair FSLogix user profile containers (VHDX files). It supports scanning entire folders, targeting specific users, or repairing individual VHDX files. The module is intended for use in environments where FSLogix profile containers are used and may become locked or corrupted.

---

## 📦 Importing the Module

To import the module in PowerShell, use the following command:

```powershell
Import-Module \\Path\To\RepairFSLogixDisk.psd1 -Force

You can call on the script and add parameters directly

FolderPath
ConnectionBroker
TargetUser
TargetVHDXPath

like
.\Scriptlocation\RepairFSLogixDisk.ps1 -FolderPath "\\FSLogixVHDFolderLocation" -connectionbroker "broker.example.com"
This will itterate through all the VHDX files in the folder. 


or 
.\Scriptlocation\RepairFSLogixDisk.ps1 -FolderPath "\\FSLogixVHDFolderLocation -TargetUser "ExampleUser" -connectionbroker "broker.example.com"
This will itterate through all the VHDX files in the userfolder. 

.\Scriptlocation\RepairFSLogixDisk.ps1 -FolderPath "\\FSLogixVHDFolderLocation -TargetVHDXPath "C:FSLogix\Profile_User.vhdx" -connectionbroker "broker.example.com"
This will repair the VHDX file.