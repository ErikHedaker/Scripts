function Test-Execute {
    param (
        [scriptblock[]]$tests,
        [int]$loops,
        [int]$executions
    )

    process {
        foreach ($i in 1..$executions) {
            Write-Host "Executing test [$i]"
            foreach ($test in $tests) {
                Test-Stopwatch $loops $test
            }
        }
    }
}

function Test-Stopwatch {
    param (
        [int]$loops,
        [scriptblock]$tests
    )

    begin {
        $stopwatch = [System.Diagnostics.Stopwatch]::new()
    }

    process {
        foreach ($test in $tests) {
            $stopwatch.Restart()
            Test-Block $loops $test
            Write-Host "{}`ttest x[$loops] took [$($stopwatch.ElapsedMilliseconds)] ms"
        }
    }
}

function Test-Block {
    param (
        [int]$loops,
        [scriptblock]$test
    )

    process {
        foreach ($null in 1..$loops) {
            Invoke-Command $test
        }
    }
}

$tests = @(
    {
        $true  ? (0>$null) : (0>$null)
        $false ? (0>$null) : (0>$null)
    },
    {
        $true  ? ($null>$null) : ($null>$null)
        $false ? ($null>$null) : ($null>$null)
    },
    {
        $true  ? (Out-Null) : (Out-Null)
        $false ? (Out-Null) : (Out-Null)
    },
    {
        ($true  ? ($null) : ($null)) > $null
        ($false ? ($null) : ($null)) > $null
    },
    {
        ($true  ? ($null) : ($null)) | Out-Null
        ($false ? ($null) : ($null)) | Out-Null
    }
)

$tests = @(
    {
        foreach($i in 1..100) {
            (($i + 1) + $i) > $null
            (($i + 1) - $i) > $null
            (($i + 1) * $i) > $null
            (($i + 1) / $i) > $null
        }
    },
    {
        foreach ($i in 1..100) {
            (($i + 1) + $i) > $null
            (($i + 1) - $i) > $null
            (($i + 1) * $i) > $null
            (($i + 1) / $i) > $null
        }
    }
)

Write-Host "[$PSCommandPath] Start"
Test-Execute $tests 10000 3
Write-Host "[$PSCommandPath] End"
Read-Host "Pause"