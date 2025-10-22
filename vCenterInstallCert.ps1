[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$downloadPath = [Environment]::GetFolderPath("UserProfile") + "\Downloads\download.zip"
$vCenterUrl = "https://<VCENTER-URL.LOCAL>/certs/download.zip"

Write-host "Henter certifikat ..." -ForegroundColor Green
curl.exe -L --insecure -o $downloadPath $vCenterUrl
start-sleep(1)

if (-not (Test-Path $downloadPath)) {
    Write-Host "Kunne ikke hente certifikat. Stopper programmet." -ForegroundColor Red
    exit
}

Write-host "Udpakker certifikat ..." -ForegroundColor Green

$downloadPath = [Environment]::GetFolderPath("UserProfile") + "\Downloads\download.zip"
$extractPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($downloadPath), "download")

if (-not (Test-Path $extractPath)) { 
    New-Item -ItemType Directory -Path $extractPath | Out-Null 
}

Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
start-sleep(1)

Write-host "Installere certifikat(er) ..." -ForegroundColor Green
Get-ChildItem -Path "$extractPath\certs\win" -Filter *.crt | ForEach-Object {
    Import-Certificate -FilePath $_.FullName -CertStoreLocation "Cert:\CurrentUser\Root"
    Write-Host "Installeret:" $_
}

Get-ChildItem -Path "$extractPath\certs\win" -Filter *.crl | ForEach-Object {
    certutil -addstore "CA" $_.FullName
    Write-Host "Installeret:" $_
}

Write-host "Rydder op ..." -foregroundcolor Red

start-sleep(5)

remove-item -Recurse $downloadPath -Force
remove-item -Recurse $extractPath -Force
