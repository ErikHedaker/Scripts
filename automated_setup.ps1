#winget --upgrade all
#Python (conda? pip?)
#VSCode
winget install --id Git.Git --accept-package-agreements
$gitPath = Join-Path $env:USERPROFILE "\AppData\Local\Programs\Git\bin"
[System.Environment]::SetEnvironmentVariable("PATH", ("{0};{1}" -f $env:PATH, $gitPath), "User")
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User")
#git remote add origin https://github.com/ErikHedaker/Scripts.git
#git pull 
#git setup code
#git fetch scripts
#https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe