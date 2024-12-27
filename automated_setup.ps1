#winget --upgrade all
#Python
#VSCode
winget install --id Git.Git --accept-package-agreements
$gitPath = Join-Path $env:USERPROFILE "\AppData\Local\Programs\Git\bin"
[System.Environment]::SetEnvironmentVariable("PATH", ("{0};{1}" -f $env:PATH, $gitPath), "User")
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User")
#git setup code
#git fetch scripts
