<#
    .SYNOPSIS
    Create an in-memory database to hold command traces

    .LINK
    https://github.com/RamblingCookieMonster/PSSQLite

    .LINK
    http://ramblingcookiemonster.github.io/SQLite-and-PowerShell/
#>

#requires -module PSSQLite

function New-Id
{
    (New-Guid) -replace '-'
}


$Connection = New-SQLiteConnection -DataSource ':MEMORY:'
if (-not ($Connection.ConnectionString -match 'Data Source=(?<DataSource>.+?);'))
{
    throw "Failed to create SQLite data source"
}
$PSDefaultParameterValues.'Invoke-SqliteQuery:SQLiteConnection' = $Connection

$Query = "
    CREATE TABLE Traces (
        Id NCHAR(32) PRIMARY KEY, 
        Function TEXT, 
        BoundParameters TEXT, 
        StartTime DATETIME,
        EndTime DATETIME
    )"
Invoke-SqliteQuery -Query $Query

if ($null -eq (Invoke-SqliteQuery -Query "PRAGMA table_info(Traces)"))
{
    throw "Failed to create Traces table"
}

$Query = "
    CREATE TABLE TraceEntries (
        Id NCHAR(32) PRIMARY KEY, 
        TraceId NCHAR(32),
        Function TEXT, 
        BoundParameters TEXT, 
        Time DATETIME,
        FOREIGN KEY (TraceId) REFERENCES Traces(Id)
    )"
Invoke-SqliteQuery -Query $Query


if ($null -eq (Invoke-SqliteQuery -Query "PRAGMA table_info(TraceEntries)"))
{
    throw "Failed to create TraceEntries table"
}


#Test it works
$TraceId = New-Id
$Function = 'Get-Stuff'
$BoundParameters = @{Stuff=22} | ConvertTo-Json -Depth 3 -Compress

Invoke-SqliteQuery -Query "
    INSERT INTO Traces (Id, Function, BoundParameters)
    VALUES ('$TraceId', '$Function', '$BoundParameters')
"

Invoke-SqliteQuery -Query "SELECT * FROM Traces"

$EntryId = New-Id
Invoke-SqliteQuery -Query "
    INSERT INTO TraceEntries (Id, TraceId, Function, BoundParameters)
    VALUES ('$EntryId', '$TraceId', '$Function', '$BoundParameters')
"


Invoke-SqliteQuery -Query "SELECT * FROM TraceEntries"