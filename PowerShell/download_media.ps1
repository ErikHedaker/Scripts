param (
    [switch]$automation
)

. .\assorted_scripts.ps1

function Resolve-FileName {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        $End
    )

    begin {
        # is_live
        $config = Get-LocalJSON 'yt-dlp' 'scripts_config.json'
        # trim non-numerical
    }

    process {
        $temp = $config.filename[0]

        if ([string]::IsNullOrEmpty($End)) {
            $temp
        } elseif ($End.Length -le 2) {
            # [int]$End < 60
            $temp
        } elseif ($End.Length -le 5) {
            # [int]$End < 3600
            $temp
        } else {
            $temp
        }
    }
}

function Get-NetworkMedia {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Position = 0)]
        [Collections.Generic.List[string]]
        $Arguments
    )

    begin {
        Write-Debug ([PipelineString]::Output($Arguments))
    }

    process {
        Write-Verbose ([PipelineString]::Output($Arguments))
        $Arguments | Out-DebugMinimal 'beginning' | Out-DebugObject -Consume
        $cut = $Arguments.Contains('--download-sections')
        $key = (Split-Path $MyInvocation.PSCommandPath -LeafBase) + ($Arguments -join '')
        <#
        $fileHandle = [PSCustomObject]@{
            GetLocalJSON
        }
        #>
        $Arguments += Get-LocalJSON $key |
            ForEach-Object {
                [ordered]@{
                    url       = Read-DefaultCondition $true $_.url 'Enter URL'
                    timeStart = Read-DefaultCondition $cut $_.timeStart 'Enter start time'
                    timeEnd   = Read-DefaultCondition $cut $_.timeEnd 'Enter end time'
                } } |
                Get-LocalJSON $key -save |
                    ForEach-Object {
                        $domain = ([System.Uri]$_.url).Host -replace '^www\.', '' -replace '\..*', ''
                        $domain = (Get-Culture).TextInfo.ToTitleCase($domain)
                        if ($cut) {
                            '*{0}-{1}' -f $_.timeStart, $_.timeEnd
                        }
                        '-o'
                        './Output/{0}/{1}' -f $domain, (Resolve-FileName $_.timeEnd)
                        $_.url }
        & yt-dlp @Arguments | Out-Host
        $LASTEXITCODE -eq 0 ? (Write-Host 'Successful exit.') : (Read-Host 'An error occurred. Press enter continue')
    }

    end {
        Write-Debug ([PipelineString]::Output($Arguments))
    }
}

function Show-Prompt {
    [CmdletBinding()]
    param ()

    begin {
        Write-Debug ([PipelineString]::Output($InputObject))
        Add-Type -AssemblyName System.Windows.Forms
        $flags = @(
            '--extract-audio',
            '--force-keyframes-at-cuts',
            '--download-sections'
        )
        $Arguments = [Collections.Generic.List[string]]::new()
        $default = '1'
        <#
        $options = @{
            '1' = @('--extract-audio')
            '2' = @('--extract-audio', '--force-keyframes-at-cuts', '--download-sections')
            '3' = @()
            '4' = @('--force-keyframes-at-cuts', '--download-sections')
        }
        #>
        $options = @{
            '1' = {
                $Arguments.Add($flags[0])
            }
            '2' = {
                $Arguments.Add($flags[0])
                $Arguments.Add($flags[1])
                $Arguments.Add($flags[2])
            }
            '3' = {}
            '4' = {
                $Arguments.Add($flags[1])
                $Arguments.Add($flags[2])
            }
        }
        # https://www.youtube.com/watch?v=eeiBCrj4-KI
    }

    process {
        Write-Verbose ([PipelineString]::Output($InputObject))
        Write-Host "Audio Full [1]`nAudio Cuts [2]`nVideo Full [3]`nVideo Cuts [4]"
        $default ? [System.Windows.Forms.SendKeys]::SendWait($default) : ($null>$null)
        $choice = Read-Host 'Enter option'
        $options[$choice].Invoke()
        Get-NetworkMedia $Arguments
        # Open explorer at resulting filepath
        # --print after_move:filepath
        Read-Host 'Exit'
    }

    end {
        Write-Debug ([PipelineString]::Output($InputObject))
    }
}

$automation ? (Get-NetworkMedia) : (Show-Prompt -Verbose -Debug)