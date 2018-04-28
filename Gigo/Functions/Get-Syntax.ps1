function Get-Syntax {
    <#
        .SYNOPSIS
        Gets the syntax for a command

        .DESCRIPTION
        Given the name of a command, gets the syntax, as provided by Powershell's extended help system.

        Syntax strings are output by parameterset.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CommandName = 'Get-ChildItem'
    )

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


    $HelpText = Get-Help $CommandName | Out-String

    <#
        E.g. for Get-ChildItem this will be:

        Get-ChildItem [[-Path] <String[]>] [[-Filter] <String>] [-Exclude <String[]>] [-Force] [-Include <String[]>] [-Name] [-Recurse] [-UseTransaction 
        <SwitchParameter>] [<CommonParameters>]
        
        Get-ChildItem [[-Filter] <String>] [-Exclude <String[]>] [-Force] [-Include <String[]>] [-Name] [-Recurse] -LiteralPath <String[]> [-UseTransaction 
        <SwitchParameter>] [<CommonParameters>]
        
    #>
    $SyntaxTextBlock = [regex]::Match(
        $HelpText,
        '(?<=SYNTAX).*?(?=DESCRIPTION|PARAMETER|EXAMPLE|INPUTS|OUTPUTS|ALIASES|RELATED LINKS|REMARKS)',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    ).Value

    #This may have strings wrapped over multiple lines, and with leading and trailing whitespace
    $SyntaxTexts = [regex]::Matches(
        $SyntaxTextBlock,
        "$CommandName.*?(?=$CommandName|$)",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    #Remove line wraps and leading and trailing whitespace
    $SyntaxTexts = $SyntaxTexts | foreach {$_.Value -replace '\r?\n\s*', ' '} | foreach {$_.Trim()}


    $SyntaxDictionary = @{}

    foreach ($SyntaxText in $SyntaxTexts)
    {
        #List of parameters from the command help
        $SyntaxParameters = [regex]::Matches($SyntaxText, '(?<= -)\w+(?= )').Value

        foreach ($ParameterSet in (Get-Command $CommandName).ParameterSets)
        {
            #List of parameters from the command metadata
            $ParticularParameters = $ParameterSet.Parameters.Name | where {$_ -notin $CommonParameters}

            if ($ParticularParameters.Count -ne $SyntaxParameters.Count) {continue}
            if ($ParticularParameters -eq $null -xor $SyntaxParameters -eq $null) {continue}
            if (-not ($ParticularParameters -eq $null -and $SyntaxParameters -eq $null) -and
                ($null -ne (Compare-Object $SyntaxParameters $ParticularParameters))) {continue}

            
            #If the two parameter lists are the same, it must be the same parameterset
            $SyntaxDictionary.Add($ParameterSet.Name, $SyntaxText)           
        }
    }

    return $SyntaxDictionary
}