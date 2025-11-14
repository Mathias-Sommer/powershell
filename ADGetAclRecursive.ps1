$Path = "L:\lokal"
$Output = "C:\ACL-Export.csv"

Write-Host "Henter mapper..."
$Folders = Get-ChildItem -LiteralPath $Path -Directory -Recurse -ErrorAction SilentlyContinue

$Results = @()

foreach ($Folder in $Folders) {
    Write-Host "ACL → $($Folder.FullName)"

    $acl = Get-Acl -LiteralPath $Folder.FullName

    foreach ($ace in $acl.Access) {
        $identity = $ace.IdentityReference.Value

        # Tjek om identity er AD-gruppe
        $isGroup = $false
        try {
            $obj = Get-ADObject -Filter "sAMAccountName -eq '$identity'" -ErrorAction Stop
            if ($obj.ObjectClass -eq "group") { $isGroup = $true }
        } catch {}

        if ($isGroup) {
            try {
                $members = Get-ADGroupMember -Identity $identity -Recursive -ErrorAction Stop
            } catch {
                $members = @()
            }

            if ($members.Count -eq 0) {
                $Results += [pscustomobject]@{
                    Folder       = $Folder.FullName
                    Identity     = $identity
                    ExpandedUser = "<empty group>"
                    Access       = $ace.FileSystemRights.ToString()
                    Type         = "Group"
                }
            }

            foreach ($m in $members) {
                $disp = try { 
                    (Get-ADUser $m.SamAccountName -ErrorAction Stop).DisplayName 
                } catch {
                    $m.Name
                }

                $Results += [pscustomobject]@{
                    Folder       = $Folder.FullName
                    Identity     = $identity
                    ExpandedUser = $disp
                    Access       = $ace.FileSystemRights.ToString()
                    Type         = "Group → User"
                }
            }
        }
        else {
            $disp = $identity
            try {
                $disp = (Get-ADUser $identity -ErrorAction Stop).DisplayName
            } catch {}

            $Results += [pscustomobject]@{
                Folder       = $Folder.FullName
                Identity     = $identity
                ExpandedUser = $disp
                Access       = $ace.FileSystemRights.ToString()
                Type         = "User"
            }
        }
    }
}

Write-Host "Eksporterer CSV..."
$Results | Export-Csv -Path $Output -NoTypeInformation -Encoding UTF8

Write-Host "Færdig → $Output"
