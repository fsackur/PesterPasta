<#
    .SYNOPSIS
    Create an in-memory database to hold command traces

    .LINK
    https://github.com/RamblingCookieMonster/PSSQLite

    .LINK
    http://ramblingcookiemonster.github.io/SQLite-and-PowerShell/
#>

#requires -module PSSQLite

#':MEMORY:'
$Connection = New-SQLiteConnection -DataSource ':MEMORY:' #([IO.Path]::GetTempFileName())
if (-not ($Connection.ConnectionString -match 'Data Source=(?<DataSource>.+?);'))
{
    throw "Failed to create SQLite data source"
}
$PSDefaultParameterValues.'Invoke-SqliteQuery:SQLiteConnection' = $Connection

$Query = "CREATE TABLE Traces (Id VARCHAR(32) PRIMARY KEY, Function TEXT, Invocation TEXT, Date DATETIME)"
Invoke-SqliteQuery -Query $Query
if ($null -eq (Invoke-SqliteQuery -Query "PRAGMA table_info(Traces)"))
{
    throw "Failed to create Traces table"
}
