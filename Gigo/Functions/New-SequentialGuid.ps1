if (-not 
    [System.AppDomain]::CurrentDomain.
        GetAssemblies().
        Where({$_.ExportedTypes.
            Where({$_.FullName -eq 'Dusty.PInvoke.SequentialUuid'})})
)
{
    Add-Type -TypeDefinition '
        using System;
        using System.Runtime.InteropServices;

        namespace Dusty.PInvoke
        {
            public class SequentialUuid
            {
                [DllImport("rpcrt4.dll")]
                public static extern int UuidCreateSequential(out Guid guid);
            }
        }
    '
}

function New-SequentialGuid
{
    [Guid]$Guid = New-Guid
    $null = [Dusty.PInvoke.SequentialUuid]::UuidCreateSequential([ref]$Guid)
    return $Guid
}