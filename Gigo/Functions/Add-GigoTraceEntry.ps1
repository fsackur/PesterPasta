function Add-GigoTraceEntry
{
    [CmdletBinding()]
    [OutputType([guid])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [guid]$TraceId
    )

    
    $TraceEntryId = New-Guid
    $Command = 'Get-Stuff'
    $BoundParameters = @{Stuff = 22} | ConvertTo-Json -Depth 3 -Compress
    $Result = "Massive success" | ConvertTo-Json -Depth 3 -Compress
    $Date = Get-Date

    Invoke-SqliteQuery -Query "
        INSERT INTO TraceEntries (Id, TraceId, Command, BoundParameters, Result, Error, Time)
        VALUES ('$TraceEntryId', '$TraceId', '$Command', '$BoundParameters', '$Result', '$Error', '$Date')
    "
}