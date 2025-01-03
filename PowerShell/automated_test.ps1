$dirPortableApps = "$env:USERPROFILE/AppData/Local/PortableApps"
if (!(Test-Path $dirPortableApps -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $dirPortableApps
}
$env:Path += ";$dirPortableApps"
[System.Environment]::SetEnvironmentVariable('PATH', $env:Path, [System.EnvironmentVariableTarget]::User)
function GetPortableApp {
    param(
        [string]$URL,
        [string]$dirOut = $dirPortableApps
    )

    $fileName = [System.IO.Path]::GetFileName($URL)
    Invoke-WebRequest -Uri $URL -OutFile "$dirOut/$fileName"
}
GetPortableApp("https://www.7-zip.org/a/7zr.exe")