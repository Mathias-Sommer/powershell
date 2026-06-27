# Useful regex for powershell

## Renaming files
Renaming all .jpg files in the current working directory using `-Replace` parameter.  
This will take all items ending with `space (1)` and replace with nothing.
```powershell
Get-ChildItem | Rename-item -Newname { $_.Name -replace ' \(1\)(?=\.jpg$)', ''}
```
