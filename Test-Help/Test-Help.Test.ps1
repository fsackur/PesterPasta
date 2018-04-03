#Help.Tests.ps1


Describe 'Function help' {
    Context 'Correctly-formatted help' {
    
        foreach (
            $Command in (
                Get-Module $ModuleName | 
                select -ExpandProperty ExportedCommands
                ).Keys
            ) 
            {
                $Help = Get-Help $Command
                
                It "$Command has one or more help examples" {
                    $Help.examples.example | Should Not Be $null
                }

                #Test only the parameters? Mock it and see if it throws
                Mock $Command -MockWith {}

                It "$Command examples are syntactically correct" {
                    foreach ($Example in $Help.examples.example) {
                        [Scriptblock]::Create($Example.code) | 
                            Should Not Throw
                    }
                }
            } #end foreach
    }
}