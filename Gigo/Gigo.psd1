
@{

# Script module or binary module file associated with this manifest.
RootModule = 'Gigo.psm1'

# Version number of this module.
ModuleVersion = '0.1'

# ID used to uniquely identify this module
GUID = 'f88fb995-38ce-4d3c-b9dc-33665c36038b'

# Author of this module
Author = 'Freddie Sackur'

# Company or vendor of this module
CompanyName = 'dustyfox.uk'

# Copyright statement for this module
Copyright = '2017'

# Description of the functionality provided by this module
Description = 'A module for accelerating test development'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

TypesToProcess = 'GigoTrace.Types.ps1xml'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Testing')
    }
}

}
