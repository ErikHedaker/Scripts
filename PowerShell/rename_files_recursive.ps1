Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("D:\CONTENT SORT 2023-02-17\Roughly Sorted")
$global:directory = Read-Host "Enter directory"
$global:indexFile = 0
$global:indexPaths = @{}
$global:fileGroups = @{}
$global:indexPathMax = 0
$global:groupCountMax = 0

function OutputDebugData {
    Write-Host "File count: $($global:indexFile)"
    Write-Host "indexPathMax: $($global:indexPathMax)"
    Write-Host "groupCountMax: $($global:groupCountMax)"
    Read-Host "Press enter to continue"
}

function GetIncrementDirectory {
    param (
        [string]$Filepath
    )

    $global:directory = [System.IO.Path]::GetDirectoryName($Filepath)

    return $global:indexPaths.$directory = ($global:indexPaths.directory ?? -1) + 1
}

function IsGroupDirectory {
    param (
        [string]$Directory = ""
    )
    
    return $false
}

function ModifyFilesAll {
    Get-ChildItem $global:directory -File -Recurse | ForEach-Object {
        $path = $_.FullName
        $timestamp = $_.CreationTime.ToString("yyyyMMddHHmmss")
        $extension = $_.Extension
        $indexFile = $global:indexFile++
        $indexPath = GetIncrementDirectory $path
        $guid = (New-Guid).ToString()
        $group = $null
        $match = $false # regex match filename from $_
        
        if ($match) {
            $guid = $match

            if (-not $global:fileGroups.ContainsKey($guid)) {
                $global:fileGroups.($guid) = [System.Collections.Generic.List[string]]::new()
            }

            $group = $global:fileGroups.($guid)
            $group.Add($path)
        } elseif ($group -and $group[0]) {
            $guid = $group[0]
        } elseif (IsGroupDirectory) {
            # $group = # Initialize $files in directory and assign $group together with $guid
            # move out of directory and delete
        }

        $groupCount = $group.Count ?? 0
        $rename = "{0:D5}_{1:D3}_{2}_{3}_{4:D5}{5}" -f $indexPath, $groupCount, $guid, $timestamp, $indexFile, $extension
        $global:indexPathMax = [Math]::Max($global:indexPathMax, $indexPath)
        $global:groupCountMax = [Math]::Max($global:groupCountMax, $groupCount)

        $path
        $rename
    }
}

function PrecomputeFileData {
    param (
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]
        $file
    )

    process {
        <#
        $group = $null
        $match = $false # regex match filename from $_
        if ($match) {
            $guid = $match

            if (-not $global:fileGroups.ContainsKey($guid)) {
                $global:fileGroups.($guid) = [System.Collections.Generic.List[string]]::new()
            }

            $group = $global:fileGroups.($guid)
            $group.Add($path)
        } elseif ($group -and $group[0]) {
            $guid = $group[0]
        } elseif (IsGroupDirectory) {
            # $group = # Initialize $files in directory and assign $group together with $guid
            # move out of directory and delete
        }
        #>
        Write-Output ([PSCustomObject]@{
            path = $PSItem.FullName
            timestamp = $PSItem.CreationTime.ToString("yyyy-MM-dd-HH-mm-ss")
            extension = $PSItem.Extension
            indexFile = $global:indexFile++
            indexPath = GetIncrementDirectory $path
            guid = (New-Guid).ToString()
        })
    }
}

function GenerateFileName {
    param (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject]
        $file
    )
    process {
        #Move grouped first files
        $name = "{0:D5}_{1:D3}_{2:D5}_{3}_{4}{5}" -f (
            $file.indexPath,
            0,
            $file.indexFile,
            $file.timestamp,
            $file.guid,
            $file.extension
        )
        $global:indexPathMax = [Math]::Max($global:indexPathMax, $indexPath)
        $global:groupCountMax = [Math]::Max($global:groupCountMax, $groupCount)
        Write-Output "Renaming file [$($file.path)] -> [$name]"
        #$newFilePath = Join-Path -Path DirectoryName -ChildPath $newFileName
        Rename-Item -Path FullName -NewName $newFilePath
    }
}

$global:extensions = @("*.png", "*.jpg", "*.jpeg", "*.jpe")
$global:matchGroup = @("!*")
Get-ChildItem "$global:directory\*" -File -Recurse -Include $global:extensions | FilePrecompute | FileModify | Write-Output
#Get-ChildItem "$global:directory\*" -Directory -Recurse -Include $global:matchGroup | Write-Output
OutputDebugData