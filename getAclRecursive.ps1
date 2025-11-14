$Path = "L:\lokal"
$Output = "C:\ACL-Export.html"

Write-Host "Henter mapper..."
$Folders = Get-ChildItem -LiteralPath $Path -Directory -Recurse -ErrorAction SilentlyContinue

$Rows = @()

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
                $Rows += [pscustomobject]@{
                    Folder       = $Folder.FullName
                    Identity     = $identity
                    ExpandedUser = "<empty group>"
                    Access       = $ace.FileSystemRights.ToString()
                    Type         = "Group"
                }
            }

            foreach ($m in $members) {
                $disp = try { 
                    $m | Get-ADUser -ErrorAction Stop | Select-Object -ExpandProperty DisplayName 
                } catch { 
                    $m.Name 
                }

                $Rows += [pscustomobject]@{
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
                $disp = Get-ADUser $identity -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
            } catch {}

            $Rows += [pscustomobject]@{
                Folder       = $Folder.FullName
                Identity     = $identity
                ExpandedUser = $disp
                Access       = $ace.FileSystemRights.ToString()
                Type         = "User"
            }
        }
    }
}

# HTML formatering (Excel åbner det som et pænt ark)
$Html = $Rows | ConvertTo-Html -Head "
<style>
table { border-collapse: collapse; font-family: Segoe UI, sans-serif; font-size: 12px; }
th { background: #eaeaea; border: 1px solid #ccc; padding: 4px; }
td { border: 1px solid #ccc; padding: 3px; }
</style>
" -Title "Folder ACL Export"

$Html | Out-File $Output -Encoding UTF8

Write-Host "Færdig → $Output"
