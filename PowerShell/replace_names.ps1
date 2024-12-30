$DEBUG = $false
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait((Get-Location))
$directory = Read-Host "Enter directory"
$name = Read-Host "Enter current name"
$replacement = Read-Host "Enter replacement name"
$textExt = "\.(txt|md|log|csv|html|xml|ps1)$";
$pattern = [regex]::Escape($name)
Get-ChildItem $directory | ForEach-Object {
    if ($_.Name -match $pattern) {
        $previous = $_.FullName
        
        if (!$DEBUG) {
            Rename-Item $_.FullName ($_.Name -replace $pattern, $replacement)
        }
        
        Write-Host "Modifying name: $previous"
    }

    if ($_.Extension -match $textExt) {
        $content = Get-Content $_.Fullname -Raw

        if ($content -match $pattern) {
            if (!$DEBUG) {
                Set-Content $_.Fullname ($content -replace $pattern, $replacement)
            }

            Write-Host "Modifying content: $($_.FullName)"
        }
    }
}
Read-Host "Press enter to exit"