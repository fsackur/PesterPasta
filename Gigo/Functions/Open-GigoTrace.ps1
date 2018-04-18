function Open-GigoTrace
{
    [CmdletBinding()]
    [OutputType([Guid])]
    param()

    $TraceId = New-Guid
    $Command = 'Get-Stuff'
    $BoundParameters = @{Stuff = 22} | ConvertTo-Json -Depth 3 -Compress
    $Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    Invoke-SqliteQuery -Query "
        INSERT INTO Traces (Id, Command, BoundParameters, StartTime)
        VALUES ('$TraceId', '$Command', '$BoundParameters', '$Date')
    "

    return $TraceId
}