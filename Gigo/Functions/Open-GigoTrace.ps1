function Open-GigoTrace
{
    [CmdletBinding()]
    [OutputType([Guid])]
    param(
        [string]$Command,
        [System.Collections.IDictionary]$BoundParameters
    )

    $TraceId = New-Guid

    $SqlSplat = [ordered]@{
        Id              = $TraceId
        Command         = $Command
        BoundParameters = $BoundParameters  | ConvertTo-Json -Depth 3 -Compress
        StartTime       = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }

    $Query = "
        INSERT INTO Traces ($($SqlSplat.Keys -join ', '))
        VALUES ('$($SqlSplat.Values -join "', '")')
    "

    Invoke-SqliteQuery -Query $Query

    return $TraceId
}