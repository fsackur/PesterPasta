<#
    .SYNOPSIS
    Create an in-memory database to hold command traces

    .LINK
    https://github.com/RamblingCookieMonster/PSSQLite

    .LINK
    http://ramblingcookiemonster.github.io/SQLite-and-PowerShell/
#>

#requires -module PSSQLite



$Connection = New-SQLiteConnection -DataSource ':MEMORY:'
if (-not ($Connection.ConnectionString -match 'Data Source=(?<DataSource>.+?);'))
{
    throw "Failed to create SQLite data source"
}
$PSDefaultParameterValues.'Invoke-SqliteQuery:SQLiteConnection' = $Connection
$PSDefaultParameterValues.'Get-Date:Format' = 'yyyy-MM-dd HH:mm:ss'

$Query = "
    CREATE TABLE Traces (
        Id NCHAR(36) PRIMARY KEY, 
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
        Id NCHAR(36) PRIMARY KEY, 
        TraceId NCHAR(36),
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


Invoke-SqliteQuery -Query "SELECT * FROM Traces"

$EntryId = New-Guid
Invoke-SqliteQuery -Query "
    INSERT INTO TraceEntries (Id, TraceId, Function, BoundParameters)
    VALUES ('$EntryId', '$TraceId', '$Function', '$BoundParameters')
"


Invoke-SqliteQuery -Query "SELECT * FROM TraceEntries"