
<#
    Hand-crafted mockup of a pester test, as a starting point.
    This will be auto-generated once I've figured out how to make it work.
    User should edit the lists of scriptblocks
#>


[ValidateSet('Capture', 'Run')][string]$GigoMode = 'Run'
$GigoModeString = switch ($GigoMode) {
    'Capture'   {'Capturing trace'}
    'Run'       {'Matches captured trace'}
}


Describe 'Command: Get-SatanicData' {

    Context 'ParameterSet: GetLostSouls' {
        # Get-SatanicData  [<CommonParameters>]

        $InvocationsToTest = @(
            {Get-SatanicData}
        )

        foreach ($Invocation in $InvocationsToTest)
        {
            It "$GigoModeString`: $Invocation" {
                $Invocation | Invoke-Gigo | Should -BeNullOrEmpty
            }
        }
    }

    Context 'ParameterSet: CondemnSoulToHell' {
        # Get-SatanicData -Soul {John Milton | Gandhi | People who drop litter}  [<CommonParameters>]

        $InvocationsToTest = @(
            {Get-SatanicData -Soul 'John Milton'},
            {Get-SatanicData -Soul 'Gandhi'},
            {Get-SatanicData -Soul 'People who drop litter'}
        )

        foreach ($Invocation in $InvocationsToTest)
        {
            It "$GigoModeString`: $Invocation" {
                $Invocation | Invoke-Gigo | Should -BeNullOrEmpty
            }
        }
    }

    Context 'ParameterSet: GetLocationOfHell' {
        # Get-SatanicData -GetLocation  [<CommonParameters>]
        
        $InvocationsToTest = @(
            {Get-SatanicData -GetLocation '127.0.0.1'}
            {Get-SatanicData -GetLocation '192.0.2.1'}
        )

        foreach ($Invocation in $InvocationsToTest)
        {
            It "$GigoModeString`: $Invocation" {
                $Invocation | Invoke-Gigo | Should -BeNullOrEmpty
            }
        }
    }

}


