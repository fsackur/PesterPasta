

$Dependencies = (
    'PSSQLite'
)

$PackagesPath = Join-Path $PSScriptRoot 'Packages'
if (-not (Test-Path $PackagesPath))
{
    $null = New-Item $PackagesPath -ItemType Directory -Force -ErrorAction Stop
}

foreach ($Dependency in $Dependencies)
{
    if (-not (Test-Path (Join-Path $PackagesPath $Dependency))) {
        Save-Module PSSQLite -Path $PackagesPath
    }
}

