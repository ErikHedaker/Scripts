param (
    [string]$fileName = "scripts_data.json",
    [string]$filePath = (Join-Path $MyInvocation.PSScriptRoot $fileName),
    [string]$scriptName = (Split-Path $MyInvocation.PSCommandPath -LeafBase),
    [switch]$DEBUG
)

$outputDEBUG = {
    $DEBUG ? (Write-Host "{ $($PSCmdlet.MyInvocation.MyCommand.Name), fileName [$fileName], filePath [$filePath], scriptName [$scriptName] }") : ($null>$null)
}

function Get-LocalJSON {
    [CmdletBinding()]
    param (
        [string]$filePath = $filePath,
        [string]$scriptName = $scriptName
    )
    Add-Content $filePath ""
    $content = (Get-Content $filePath -Raw | ConvertFrom-Json -AsHashtable) ?? @{}
    $content.scriptName ?? @{}
    & $outputDEBUG
}

function Set-LocalJSON {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$data,
        [string]$filePath = $filePath,
        [string]$scriptName = $scriptName
    )
    Add-Content $filePath ""
    $content = (Get-Content $filePath -Raw | ConvertFrom-Json -AsHashtable) ?? @{}
    $content.scriptName = $data
    $content | ConvertTo-Json -Depth 2 | Set-Content $filePath
    & $outputDEBUG
}