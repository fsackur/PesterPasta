function Close-GigoTrace
{
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [guid]$Id
    )

    $TraceId = $Id
    $Date = Get-Date

    Invoke-SqliteQuery -Query "
        UPDATE Traces
        SET EndTime = '$Date'
        WHERE Id = '$TraceId'
    "
}