# Gem AD SIDs for alle brugere og grupper
$OutputCsv = "C:\temp\AD_Users_Groups_SIDs.csv"

$ADObjects = @()

# Brugere
Get-ADUser -Filter * -Properties SID | ForEach-Object {
    $ADObjects += [PSCustomObject]@{
        Name = $_.SamAccountName
        DisplayName = $_.Name
        Type = "User"
        SID = $_.SID.Value
    }
}

# Grupper
Get-ADGroup -Filter * -Properties SID | ForEach-Object {
    $ADObjects += [PSCustomObject]@{
        Name = $_.SamAccountName
        DisplayName = $_.Name
        Type = "Group"
        SID = $_.SID.Value
    }
}

# Gem til CSV
$ADObjects | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Færdig. AD brugere og grupper gemt til $OutputCsv"
