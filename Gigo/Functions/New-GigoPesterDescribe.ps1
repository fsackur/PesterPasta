function New-GigoPesterDescribe {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$CommandName = 'Get-SatanicData',

        [Parameter()]
        [string]$OutFile = '.\GigoTrace.Template.Test.ps1'
    )

    $Command = Get-Command $CommandName
    [uint16]$NestLevel = 0
    $SB = New-Object System.Text.StringBuilder (10000)

    $CommonParameters = (
        'Verbose',
        'Debug',
        'ErrorAction',
        'WarningAction',
        'InformationAction',
        'ErrorVariable',
        'WarningVariable',
        'InformationVariable',
        'OutVariable',
        'OutBuffer',
        'PipelineVariable'
    )

    $SyntaxDictionary = Get-Syntax $CommandName



    $null = $SB.AppendLine("Describe 'Command: $Command' {").AppendLine()
    $NestLevel++


    foreach ($ParameterSet in $Command.ParameterSets)
    {
        $null = $SB.AppendLine("Context 'ParameterSet: $($ParameterSet.Name)' {").AppendLine()
        $NestLevel++


        $null = $SB.Append('# ').AppendLine($SyntaxDictionary[$ParameterSet.Name])
        #$ParticularParameters
        #stuff




        $null = $SB.AppendLine("}").AppendLine()
        $NestLevel--
    }

    $null = $SB.AppendLine("}").AppendLine()
    $NestLevel--

    $SB.ToString() | Out-File $OutFile

    Import-Module (Join-Path $PackagePath 'PowerShell-Beautifier') -Global   #Seems to be unhappy as a nested module
    Edit-DTWBeautifyScript $OutFile -IndentType FourSpaces
}