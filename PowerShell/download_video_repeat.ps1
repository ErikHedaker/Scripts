# Copy of download_video_cut.ps1
$scriptName = Split-Path $PSCommandPath -LeafBase
$outputName = "%(title)s {%(id)s, %(section_start-3600>%M_%S)s-%(section_end-3600>%M_%S)s}.%(ext)s"
$outputPath = "Output/$outputName"
$contentName = "scripts_data.json"
$contentPath = Join-Path $PSScriptRoot $contentName
Add-Content $contentPath ""
$content = (Get-Content $contentPath -Raw | ConvertFrom-Json -AsHashtable) ?? @{}
$data = $content.$scriptName ?? @{}
$data.url       = ($temp = Read-Host "Enter URL (empty input for [$($data.url)])")              ? $temp : $data.url
$data.timeStart = ($temp = Read-Host "Enter start time (empty input for [$($data.timeStart)])") ? $temp : $data.timeStart
$data.timeEnd   = ($temp = Read-Host "Enter end time   (empty input for [$($data.timeEnd)])")   ? $temp : $data.timeEnd
$content.$scriptName = $data
$content | ConvertTo-Json -Depth 2 | Set-Content $contentPath
& yt-dlp --force-keyframes-at-cuts --download-sections "*$($data.timeStart)-$($data.timeEnd)" -o $outputPath $data.url
$LASTEXITCODE -eq 0 ? (Write-Host "Successful exit.") : (Read-Host "An error occurred. Press enter continue")

# Actual code for download_video_repeat.ps1
