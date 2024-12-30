$content = (Get-Clipboard -Raw | Where-Object { $_.Length -le 200 }) ?? ""
$pattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
$guid = [guid]::NewGuid().ToString()
Set-Clipboard (($content -match $pattern) ? ($content -replace $pattern, $guid) : $content + $guid )