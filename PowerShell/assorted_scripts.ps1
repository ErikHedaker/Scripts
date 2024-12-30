if (-not $MyInvocation.PSCommandPath) {
    Read-Host "Do not direct invoke [$($MyInvocation.MyCommand.Source)]"
}

class Utility {
    static [bool] IsCollection($InputObject) {
        return ($InputObject -is [System.Collections.IEnumerable] -and (-not ($InputObject -is [string])))
    }
    static [void] InfoDumpObject($InputObject) {
        @(
            { $InputObject.GetType().BaseType.GetProperties() | Select-Object -Property * | Out-Host },
            { $InputObject.GetType().BaseType | Select-Object -Property * | Out-Host },
            { $InputObject | Select-Object -Property * | Out-Host },
            { $InputObject.GetType().BaseType | Get-Member -Force | Out-Host },
            { $InputObject | Get-Member -Force | Out-Host }
        ) | ForEach-Object {
            Write-Host $_ -ForegroundColor Magenta
            $_.Invoke()
        } > $null
    }
}
class PipelineString {
    static [hashtable]$Counter = @{}

    static [int] Incrementer([string]$key) {
        if (-not [PipelineString]::Counter.ContainsKey($key)) {
            [PipelineString]::Counter[$key] = -1
        }

        return ++[PipelineString]::Counter[$key]
    }

    static [string] Output([PSObject]$InputObject) {
        $stack = Get-PSCallStack
        $nameCaller = $stack[1].FunctionName
        $nameOrigin = $stack[2].FunctionName
        $type = $InputObject ? $InputObject.GetType().Name : ''
        $key = $nameCaller + $nameOrigin + $type
        $index = [PipelineString]::Incrementer($key)
        $output = (" `t({0}) -> [{1}] -> ({2})" -f $nameOrigin, $index, $nameCaller)
        $output += $InputObject ? " `$InputObject is [$type]" : ''
        return $output
    }
}
function Out-DebugMinimal {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$message,
        [Parameter(ValueFromPipeline)]
        $InputObject,
        [switch]$Consume
    )

    process {
        $stack = Get-PSCallStack
        Write-Host ('({0}) {1}' -f $stack[0].FunctionName, $message) -ForegroundColor DarkCyan
        Write-Host ('({0}) <-- ({1}) <-- ({2})' -f $stack[0].FunctionName, $stack[1].FunctionName, $stack[2].FunctionName)
        Write-Host ('({0}) --> [{1}]$InputObject' -f $stack[0].FunctionName, $InputObject.GetType().FullName)
        Write-Host ('({0}) --> $InputObject | Out-Host:' -f $stack[0].FunctionName)
        $InputObject | Out-Host
        if (-not $Consume) {
            $InputObject
        }
    }
}
function Out-DebugObject {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$message,
        [Parameter(Position = 1)]
        [string]$format = 'Format-List',
        [Parameter(ValueFromPipeline)]
        $InputObject,
        [switch]$Batch,
        [switch]$Dump,
        [switch]$Consume
    )

    begin {
        Write-Debug ([PipelineString]::Output($InputObject))
        $property = @{
            'Format-Table' = @{'-Force' = $true; '-Expand' = 'Both' }
            'Format-List'  = @{'-Force' = $true }
        }
        $include = @(
            @{ N = 'Type'; E = { '[{0}]' -f $_.GetType().Name } },
            @{ N = 'Value'; E = { ($_.Value ?? $_) ?? '$null' } },
            '*'
        )
        <# -ExcludeProperty $exclude
        $exclude = $Dump ? @() : @(
            'ScriptContents', 'Definition',
            'ScriptBlock', 'Line',
            'Statement', 'PositionMessage',
            'UnboundArguments', 'ScriptLineNumber',
            'OffsetInLine', 'HistoryId'
        )
        #>
        $collect = @()
    }

    process {
        Write-Verbose ([PipelineString]::Output($InputObject))
        Write-Host ('({0}) {1}' -f $PSCmdlet.MyInvocation.MyCommand.Name, $message) -ForegroundColor DarkCyan
        if ($Batch) {
        $collect += $InputObject |
                Select-Object -Property $include
        } else {
        $InputObject |
                Select-Object -Property $include |
                    Invoke-Function $format -Argument $property[$format] |
                        Out-String |
                            Out-Host
        }
        if (-not $Consume) {
            $InputObject
        }
    }

    end {
        $OutHost = @{
            'Format-Table' = {
                $_ | Out-Host
            }
            'Format-List'  = {
                $_ |
                    ForEach-Object {
                        (($_.Trim() + "`n") -split '(?m)(?=^\s*Type\s*:)' |
                            Where-Object { $_.Trim() -ne '' } |
                                ForEach-Object { "[`n$_]" }) -join ',' } |
                        Out-Host
            }
        }
        if ($Batch) {
            Write-Host "Collection:`n" -ForegroundColor DarkCyan
            [Utility]::IsCollection($InputObject) ? (, $InputObject) : (, $collect) |
                Select-Object -Property $include |
                    Format-List -Expand CoreOnly |
                        Out-String |
                            ForEach-Object { $_.Trim() } |
                                Out-Host
            Write-Host "`nCollection[elements]:" -ForegroundColor DarkCyan
            , $collect |
                Invoke-Function $format -Argument $property[$format] |
                    Out-String |
                        ForEach-Object $OutHost[$format]
        }
        if ($Dump) {
            [Utility]::InfoDumpObject($InputObject)
        }
        Write-Debug ([PipelineString]::Output($InputObject))
    }
}
function Invoke-Function {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name,
        [hashtable]$Argument = @{},
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Remaining = @(),
        [Parameter(ValueFromPipeline)]
        [PSObject]$InputObject
    )

    process {
        $InputObject | & $Name @Argument @Remaining
    }
}
function Read-DefaultCondition {
    param (
        [bool]$Execute = $true,
        [string]$Default,
        [string]$Prompt
    )

    begin {
        if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.SendKeys').Type) {
            Add-Type -AssemblyName System.Windows.Forms
        }
        <#
        if (-not ('System.Windows.Forms.SendKeys' -as [type])) {
            Add-Type -AssemblyName System.Windows.Forms
        }
        #>
    }

    process {
        if (!$Execute) {
            return
        }

        if ($Prompt) {
            $Default ? [System.Windows.Forms.SendKeys]::SendWait($Default) : ($null>$null)
            Read-Host $Prompt
        } else {
            $Default
        }
    }
}
function Get-LocalJSON {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Position = 0)]
        [string]$key = (Split-Path $MyInvocation.PSCommandPath -LeafBase),
        [Parameter(Position = 1)]
        [string]$fileName = 'scripts_data.json',
        [switch]$save,
        [Parameter(ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject
    )

    begin {
        Write-Debug ([PipelineString]::Output($InputObject))
        $filePath = Join-Path $MyInvocation.PSScriptRoot $fileName
        Add-Content $filePath ''
        $fileData = (Get-Content $filePath -Raw | ConvertFrom-Json -AsHashtable) ?? [ordered]@{}
    }

    process {
        Write-Verbose ([PipelineString]::Output($InputObject))
        if ($save) {
            $fileData.$key = $InputObject ?? $fileData.$key
        }

        $fileData.$key ?? [ordered]@{}
    }

    end {
        if ($save) {
            $fileData |
                ConvertTo-Json |
                    Set-Content $filePath -PassThru |
                        Out-DebugObject > $null
        }
        Write-Debug ([PipelineString]::Output($InputObject))
    }
}

<#
        $Argument
        if ($cut) {
            '*{0}-{1}' -f $_.timeStart, $_.timeEnd
        }
        '-o'
        './Output/{0}/{1}' -f $domain, (Resolve-FileName $cut $_.timeEnd)
        $_.url
        #>