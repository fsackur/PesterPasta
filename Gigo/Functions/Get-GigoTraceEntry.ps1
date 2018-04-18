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
        "
    }

    $Result = Invoke-SqliteQuery -Query $Query
    @($Result).ForEach({$_.PSTypeNames.Insert(0, 'Dusty.GigoTraceEntry')})
    return $Result
}