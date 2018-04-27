function New-GigoPesterTemplate
{
    [CmdletBinding(DefaultParameterSetName = 'FromJsonFile')]
    [OutputType([void])]
    param (
        [Parameter(ParameterSetName = 'FromJsonFile')]
        [string]$Path = '.\GigoTrace.Config.json',

        [Parameter(ParameterSetName = 'FromPSObject', Mandatory = $true)]
        [psobject]$TraceConfig,

        [Parameter()]
        [string]$OutFile = '.\GigoTrace.Template.Test.ps1'
    )

    $Accelerators = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get
    $SB = New-Object System.Text.StringBuilder (10000)

    
    if ($PSCmdlet.ParameterSetName -eq 'FromJsonFile')
    {
        $TraceConfig = Get-Content $Path -Raw | ConvertFrom-Json
    }

    $Commands = $TraceConfig.Command | sort -Unique

    foreach ($Command in $Commands)
    {

        $null = $SB.AppendLine("Describe 'Command: $Command' {").AppendLine()

        $Contexts = $TraceConfig | where {$_.Command -eq $Command}
        foreach ($Context in $Contexts)
        {

            $null = $SB.AppendLine("Context 'ParameterSet: $($Context.ParameterSet)' {").AppendLine()


            foreach ($Parameter in $Context.Parameters) {

                $Accel = $Accelerators.GetEnumerator() | 
                    where {$_.Value.FullName -eq $Parameter.ParameterType} | 
                    select -ExpandProperty Key

                $Type = if ($Accel) {$Accel} else {$Parameter.ParameterType -replace '.*\.'}

                $null = $SB.AppendLine("[$Type]`$$($Parameter.Name)").AppendLine()
            }


            $null = $SB.AppendLine("}").AppendLine()
        }

        $null = $SB.AppendLine("}")
    }

    $SB.ToString() | Out-File $OutFile

    Import-Module (Join-Path $PackagePath 'PowerShell-Beautifier')
    Edit-DTWBeautifyScript $OutFile -IndentType FourSpaces
}