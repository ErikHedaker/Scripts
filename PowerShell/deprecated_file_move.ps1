Add-Type -AssemblyName System.Windows.Forms
. .\local_json.ps1 -DEBUG
$values = @{}
$values.data = Get-LocalJSON
$values.parents = ($data.common_parent_directories ?? @()) -join "|"
[System.Windows.Forms.SendKeys]::SendWait("D:\Scripts\deprecated_file_move.ps1")
$values.filepath = [System.IO.Path]::GetFullPath((Read-Host "Enter file path"))
$values.current = [System.IO.DirectoryInfo]::new($values.filepath)
$values.common = $null

while ($null -ne $values.current) {
    Write-Host "`$values.current [$($values.current)]"

    if ($values.parents.Contains($values.current.FullName)) {
        $values.common = $values.current.FullName
        break
    }

    $values.current = $values.current.Parent
}

if (!$values.common) {
    [System.Windows.Forms.SendKeys]::SendWait($PSScriptRoot)
    Write-Host "No common parent directory was found"
    $values.common = Read-Host "Enter directory path"
    [System.IO.Path]::Exists($values.common) ? ($null>$null) : (throw "Error")
}

$values.relative = [System.IO.Path]::GetRelativePath($values.common, $values.filepath)
$values.destination = (Join-Path $values.common "\Deprecated\" $values.relative)
$values

Read-Host "Press enter to exit"