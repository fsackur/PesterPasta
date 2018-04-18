function Add-GigoTraceEntry {
    [CmdletBinding()]
    [OutputType([guid])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [guid]$TraceId,

        [string]$Command,

        [System.Collections.IDictionary]$BoundParameters,

        [object]$Result,

        [object]$Error
    )

    $SqlSplat = [ordered]@{
        Id              = New-Guid
        TraceId         = $TraceId
        Command         = $Command
        BoundParameters = $BoundParameters  | ConvertTo-Json -Depth 3 -Compress
        Result          = $Result           | ConvertTo-Json -Depth 3 -Compress
        Error           = $Error            | ConvertTo-Json -Depth 3 -Compress
        Time            = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Ticks           = (Get-Date).Ticks
    }

    $Query = "
        INSERT INTO TraceEntries ($($SqlSplat.Keys -join ', '))
        VALUES ('$($SqlSplat.Values -join "', '")')
    "

    Invoke-SqliteQuery -Query $Query
}