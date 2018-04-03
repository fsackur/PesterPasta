function Get-GigoTrace
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([psobject])]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0)]
        [guid]$Id
    )

    $TraceId = $Id
    $Date = Get-Date

    if ($PSCmdlet.ParameterSetName -eq 'ById')
    {
        $Query = "
            SELECT * FROM Traces
            WHERE Id = '$TraceId'
        "
    }
    else
    {
        $Query = "SELECT * FROM Traces"
    }

    $Result = Invoke-SqliteQuery -Query $Query
    @($Result).ForEach({$_.PSTypeNames.Insert(0, 'Dusty.GigoTrace')})
    return $Result
}