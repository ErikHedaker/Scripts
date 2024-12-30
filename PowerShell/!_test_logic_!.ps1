. .\assorted_scripts.ps1

function Temp {
    try {

    } catch {
        <#Do this if a terminating exception happens#>
        Read-Host 'Caught error'
    }

    #[System.Reflection.ParameterInfo]::new
    <#
    $assembly = [System.Reflection.Assembly]::LoadFrom('C:\temp\mytestlib.dll')
    $type = $assembly.GetType('ExampleProject.Class1')
    $method = $type.GetMethod('RunProcess')
    $method.Invoke($null, @('C:\Windows\System32\calc.exe'))
    #>
}

function Test-DynamicScriptblockChatGPT {
    <# Pseudo code by me
$scriptblock_base = { param($thing) "Hello $thing" }
$scriptblock_parameter_to_preassign = @("Erik", "World")
$scriptblocks_with_preassigned_values = @()
foreach ($thing in $scriptblock_parameter_to_preassign) {
    $scriptblocks_with_preassigned_values += $scriptblock_base.PreAssign($thing) # PreAssign method doesn't exist, it is pseudocode to bind value to scriptblock
}
# ... imagine code stuff happening here ...
foreach ($scriptblock in $scriptblock_with_preassigned_value) {
    $result = $scriptblock.InvokeWithPreAssign() # InvokeWithPreAssignPreAssign method doesn't exist, it is pseudocode to invoke scriptblock with preassigned value ($thing from above)
    Write-Host $result
}
# Console output from loop 1: "Hello Erik"
# Console output from loop 2: "Hello World"
#>

    # Base script block that takes a parameter
    $scriptblock_base = { param($thing) "Hello $thing" }

    # Array of parameters to pre-assign
    $scriptblock_parameters_to_preassign = @('Erik', 'World')

    # Array to store script blocks with pre-assigned values
    $scriptblocks_with_preassigned_values = @()

    # Loop through each parameter and create a script block with pre-assigned value
    foreach ($thing in $scriptblock_parameters_to_preassign) {
        # Create a new script block that captures the current value of $thing
        $scriptblocks_with_preassigned_values += {
            # This new script block "remembers" the value of $thing at the time it was created
            param()
            & $scriptblock_base -thing $thing  # Invoke the base script block with the pre-assigned value
        }
    }

    # ... imagine code stuff happening here ...

    # Loop through the script blocks with pre-assigned values and invoke them
    foreach ($scriptblock in $scriptblocks_with_preassigned_values) {
        $result = $scriptblock.Invoke()  # Invoke the script block
        Write-Host $result
    }

    # Expected output:
    # Hello Erik
    # Hello World
}

function Test-DynamicScriptblock {
    #$base = { param($thing) "Hello $thing" }
    $values = @('Erik', 'World')
    $scriptblocks = @()
    foreach ($value in $values) {
        #$scriptblocks += $base.PreAssign($thing)

        #$string = { "Hello $value" }
        $scriptblocks += [scriptblock]::create('{ "Hello $value" }')
    }
    foreach ($scriptblock in $scriptblocks) {
        #$result = $scriptblock.InvokeWithPreAssign()
        $result = $scriptblock.Invoke()
        Write-Host $result
    }
}

function Test-DynamicFunction {
    function OutputThing {
        'Thing'
    }
    #$function = "OutputThing"
    #$type = [type]"string"
    $result1 = (OutputThing -is [type])
    $result2 = OutputThing
    $result3 = $function

    # The following:
    $result4 = [string]::Concat('foo', 'bar') # -> 'foobar'

    # ... can also be expressed as:
    $type = [type] 'string'
    $method = 'Concat'
    $result5 = $type::$method('foo', 'bar')
    $result6 = (OutputThing).GetType().Name


    Write-Host "`$result1 [$result1]"
    Write-Host "`$result2 [$result2]"
    Write-Host "`$result3 [$result3]"
    Write-Host "`$result4 [$result4]"
    Write-Host "`$result5 [$result5]"
    Write-Host "`$result6 [$result6]"
}

#Test-DynamicScriptblock
#Test-DynamicFunction
Test-Pipeline -Verbose -Debug
Read-Host 'Exit'