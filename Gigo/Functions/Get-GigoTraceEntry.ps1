function Get-GigoTraceEntry
{
    [CmdletBinding(DefaultParameterSetName = 'ByTraceId')]
    [OutputType([psobject[]])]
    param(
        [Parameter(ParameterSetName = 'ByTraceId', Mandatory = $true, Position = 0)]
        [guid]$TraceId,

        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0)]
        [guid]$Id
    )

    $TraceEntryId = $Id

    if ($PSCmdlet.ParameterSetName -eq 'ByTraceId')
    {
        $Query = "
            SELECT * FROM TraceEntries
            WHERE TraceId = '$TraceId'
        "
    }
    else
    {
        $Query = "
            SELECT * FROM TraceEntries
            WHERE Id = '$TraceEntryId'
            ORDER BY TraceId, TICKS
        "
    }

    $Result = Invoke-SqliteQuery -Query $Query | select (
        'Id',
        'TraceId',
        'Command',
        @{Name='BoundParameters';   Expression={$_.BoundParameters  | ConvertFrom-Json}},
        @{Name='Result';            Expression={$_.Result           | ConvertFrom-Json}},
        @{Name='Error';             Expression={$_.Error            | ConvertFrom-Json}},
        @{Name='Time';              Expression={Get-Date $_.Time}},
        'Ticks'
    )
    @($Result).ForEach({$_.PSTypeNames.Insert(0, 'Dusty.GigoTraceEntry')})
    return $Result
}