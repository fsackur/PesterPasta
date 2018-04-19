function New-GigoTraceConfig {
    param (
        [string]$Module,

        [switch]$AsJson
    )

    $Commands = Get-Command -Module $Module
    
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

    $Output = @()

    foreach ($Command in $Commands)
    {
        $ParameterSets = @()

        foreach ($ParameterSet in $Command.ParameterSets)
        {
            $Parameters = @()

            foreach ($Parameter in ($ParameterSet.Parameters | where {$_.Name -notin $CommonParameters}))
            {
                $CookedAttributes = @()
                
                foreach ($Attribute in $Parameter.Attributes) {

                    #Subset of possible parameter validation attributes (e.g. disregard ValidateDrive or ValidateCount)
                    if ($Attribute -isnot [System.Management.Automation.ValidateEnumeratedArgumentsAttribute])
                    {
                        continue
                    }

                    $TypeName = $Attribute.TypeId.Name -replace 'Attribute$'

                    $ValidArg = switch ($TypeName)
                    {
                        'ValidateLength'    {$Attribute.MinLength, $Attribute.MaxLength}
                        'ValidateRange'     {$Attribute.MinRange, $Attribute.MaxRange}
                        'ValidatePattern'   {$Attribute.RegexPattern}
                        'ValidateScript'    {$Attribute.ScriptBlock}
                        'ValidateSet'       {$Attribute.ValidValues}
                    }

                    $CookedAttribute = New-Object psobject -Property @{
                        TypeName = $TypeName
                        ValidArg = $ValidArg
                    }
                    $CookedAttribute | Add-Member ScriptMethod -Name ToString -Force -Value {
                        return "[{0}({1})]" -f (
                            $this.TypeName,
                            $(switch -Regex ($this.TypeName) {
                                'Set'           {"'$($this.ValidArg -join "', '")'"}
                                'Length|Range'  {"$($this.ValidArg -join ', ')"}
                                'Pattern'       {"'$($this.ValidArg)'"}
                                'Script'        {"{$($this.ValidArg)}"}
                            })
                        )
                    }
                    $CookedAttributes += $CookedAttribute
                }

                $Parameters += New-Object psobject -Property @{
                    Name               = $Parameter.Name
                    ParameterType      = $Parameter.ParameterType.FullName
                    IsMandatory        = $Parameter.IsMandatory
                    ValidateAttributes = @($CookedAttributes)
                }
            }

            $ParameterSets += New-Object psobject -Property ([ordered]@{
                Command      = $Command.Name
                ParameterSet = $ParameterSet.Name
                Parameters   = @($Parameters)
            })
        }

        $Output += $ParameterSets
    }
    
    if ($AsJson)
    {
        ($Output | ConvertTo-Json -Depth 4) -replace '\\u0027', "'"
    }
    else
    {
        $Output
    }
}