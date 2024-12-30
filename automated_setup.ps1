#winget --upgrade all
#Python (conda? pip?)
#VSCode
winget install --id Git.Git --accept-package-agreements
#$gitPath = Join-Path $env:USERPROFILE '\AppData\Local\Programs\Git\bin'
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
#https://stackoverflow.com/questions/714877/setting-windows-powershell-environment-variables
#[Environment]::SetEnvironmentVariable('INCLUDE', $env:INCLUDE, [System.EnvironmentVariableTarget]::User))
#[System.Environment]::SetEnvironmentVariable("PATH", ("{0};{1}" -f $env:PATH, $gitPath), "User")
#git remote add origin https://github.com/ErikHedaker/Scripts.git
#git pull
#git setup code
#git fetch scripts
#https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe