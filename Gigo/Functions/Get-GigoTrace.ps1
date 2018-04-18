function Get-GigoTrace
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([psobject])]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory = $true, Position = 0)]
        [guid]$Id
    )

    $TraceId = $Id
    $Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

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

    $Result = Invoke-SqliteQuery -Query $Query | select (
        'Id',
        'Command',
        @{Name='BoundParameters';   Expression={$_.BoundParameters | ConvertFrom-Json}},
        @{Name='StartTime';         Expression={Get-Date $_.StartTime}},
        @{Name='EndTime';           Expression={Get-Date $_.EndTime}}
    )
    @($Result).ForEach({$_.PSTypeNames.Insert(0, 'Dusty.GigoTrace')})
    return $Result
}