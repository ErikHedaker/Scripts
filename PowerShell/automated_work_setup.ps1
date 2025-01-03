#winget --upgrade all
#Python (conda? pip?)
#VSCode
#ms-vscode.powershell
#ironmansoftware.powershellprotools
#tobysmith568.run-in-powershell
#yinfei.luahelper
#ms-python.debugpy
#ms-python.python
#ms-python.vscode-pylance
winget install --id Git.Git --accept-package-agreements
$cli7zURL = "https://www.7-zip.org/a/7zr.exe"
$cli7zFile = "{0}/{1}" -f $env:USERPROFILE, [System.IO.Path]::GetFileName($url7z)
Invoke-WebRequest -Uri $cli7zURL -OutFile $cli7zFile
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
#set chrome as default app? "C:\Program Files\Google\Chrome\Application\chrome.exe"