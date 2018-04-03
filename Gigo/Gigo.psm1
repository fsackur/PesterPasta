

Import-Module $PSSCriptRoot\Packages\PSSQLite
. $PSScriptRoot\Initialize-TraceDB.ps1

function Trace-RestMethod
{
    <#
    .SYNOPSIS
    Capture input and output of Invoke-RestMethod to a trace file

    .DESCRIPTION
    When writing unit tests for API clients, it is very useful to pull real data that can be used for mocking. This
    function helps generate mock data. Simply run all the commands that you wish to write tests for and mock data is 
    traced in JSON format.

    This captures the input to the -Body parameter of, and the return from, Invoke-RestMethod.

    .PARAMETER Tracefile
    The file to save mock data in JSON format

    .PARAMETER UriFilter
    String which will be used for regex match on the URI of any API calls. Only URIs matching the filter will be traced.

    .PARAMETER Off
    Stops tracing and properly terminates the trace file so that it is valid json.

    .EXAMPLE
    Trace-RestMethod.ps1 .\RestMethodTrace.json -UriFilter 'https://api.service.com/api/v2'
    Invoke-MyApiCall -Parameter1 $P1
    Invoke-MyApiCall -Parameter1 $P1
    Trace-RestMethod.ps1 -Off

    Captures inputs and outputs of REST method calls to api.service.com to file RestMethodTrace.json.

    #>

    [CmdletBinding(DefaultParameterSetName = 'On', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param (
        [Parameter(ParameterSetName = 'On', Position = 0, Mandatory = $true)]
        [string]$TraceFile,

        [Parameter(ParameterSetName = 'On')]
        [string]$UriFilter = '.*',

        [Parameter(ParameterSetName = 'On')]
        [switch]$On,

        [Parameter(ParameterSetName = 'On')]
        [switch]$Force,

        [Parameter(ParameterSetName = 'Off', Mandatory = $true)]
        [switch]$Off
    )

    #requires -version 3.0

    $FunctionPath = "Function:\Invoke-RestMethod"

    if ($PSCmdlet.ParameterSetName -eq 'Off')
    {
        $TraceFile = (Get-Command Invoke-RestMethod -CommandType Function).Module.SessionState.PSVariable.GetValue('TraceFile')
        if (Test-Path $TraceFile)
        {
            ']' | Out-File $TraceFile -Encoding utf8 -Append
        }
        if (Test-Path $FunctionPath)
        {
            Remove-Item $FunctionPath -Force
        }

        Write-Verbose "RestMethod tracing off" -Verbose
        return
    }

    $BasePath = Split-Path $TraceFile
    if ([string]::IsNullOrWhiteSpace($BasePath)) {$BasePath = $PWD}
    $BasePath = Resolve-Path $BasePath
    if (-not (Test-Path $BasePath))
    {
        New-Item $BasePath -ItemType Directory -Force -ErrorAction Stop -Confirm:$Confirm
    }
    $TraceFile = Join-Path $BasePath (Split-Path $TraceFile -Leaf)


    #Generated with Metaprogramming module
    $FunctionDef = {
        <#
        .ForwardHelpTargetName Microsoft.PowerShell.Utility\Invoke-RestMethod
        .ForwardHelpCategory Cmdlet
        #>
        [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=217034')]
        param(
            [Microsoft.PowerShell.Commands.WebRequestMethod]
            ${Method},

            [switch]
            ${UseBasicParsing},

            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateNotNullOrEmpty()]
            [uri]
            ${Uri},

            [Microsoft.PowerShell.Commands.WebRequestSession]
            ${WebSession},

            [Alias('SV')]
            [string]
            ${SessionVariable},

            [pscredential]
            [System.Management.Automation.CredentialAttribute()]
            ${Credential},

            [switch]
            ${UseDefaultCredentials},

            [ValidateNotNullOrEmpty()]
            [string]
            ${CertificateThumbprint},

            [ValidateNotNull()]
            [X509Certificate]
            ${Certificate},

            [string]
            ${UserAgent},

            [switch]
            ${DisableKeepAlive},

            [ValidateRange(0, 2147483647)]
            [int]
            ${TimeoutSec},

            [System.Collections.IDictionary]
            ${Headers},

            [ValidateRange(0, 2147483647)]
            [int]
            ${MaximumRedirection},

            [uri]
            ${Proxy},

            [pscredential]
            [System.Management.Automation.CredentialAttribute()]
            ${ProxyCredential},

            [switch]
            ${ProxyUseDefaultCredentials},

            [Parameter(ValueFromPipeline = $true)]
            [System.Object]
            ${Body},

            [string]
            ${ContentType},

            [ValidateSet('chunked', 'compress', 'deflate', 'gzip', 'identity')]
            [string]
            ${TransferEncoding},

            [string]
            ${InFile},

            [string]
            ${OutFile},

            [switch]
            ${PassThru}
        )

        if (-not $UriFilter) {throw "Closure not created properly"}
        if ($Uri -notmatch $UriFilter)
        {
            #Don't trace - run the original query and return
            return Microsoft.PowerShell.Utility\Invoke-RestMethod @PSBoundParameters
        }

        #If we're still here, we're tracing
        Write-Verbose "$Uri matches $UriFilter. Tracing REST method to file $TraceFile"

        if (-not $TraceFile) {throw "Closure not created properly"}
        $BasePath = Split-Path $TraceFile
        if (-not (Test-Path $BasePath))
        {
            New-Item $BasePath -ItemType Directory -Force -ErrorAction Stop -Confirm:$Confirm
        }
        if (-not (Test-Path $TraceFile))
        {
            '[' | Out-File $TraceFile -Encoding utf8
        }
        else
        {
            ',' | Out-File $TraceFile -Encoding utf8 -Append
        }

    
        $TraceProperties = [ordered]@{
            ApiInput     = $null
            ApiOutput    = $null
            ApiException = $null        
        }
        $TraceObject = New-Object psobject -Property $TraceProperties

        $TraceObject.ApiInput = $PSBoundParameters

        try 
        {
            #Run the real query
            $Output = Microsoft.PowerShell.Utility\Invoke-RestMethod @PSBoundParameters
        }
        catch
        {
            $TraceObject.ApiException = $_.Exception
            throw
        }
        finally
        {
            $TraceObject.ApiOutput = $Output  #presumably, null
        }

        $TraceObject | ConvertTo-Json -Depth 10 | Out-File $TraceFile -Encoding utf8 -Append
    
        return $Output
    }
    #This embeds the values of $TraceFile and $UriFilter into the scriptblock
    $Closure = $FunctionDef.GetNewClosure()
    Set-Item Function:Global:$(Split-Path $FunctionPath -Leaf) $Closure
    Write-Verbose "RestMethod tracing on" -Verbose
}


function Trace-SutCommand
{
    <#
    .SYNOPSIS
    Capture input and output of a command to file

    .DESCRIPTION
    "SUT" is an abbreviation for "system under test". This command assists with black-box testing by letting the user
    capture output for a given input. This speeds the development of a collection of tests for an existing system.

    Proxy commands are generated for each command being traced, and can be seen in the module table with the name
    'PastaTracingProxy'. THe proxy commands clobber the commands being traced. Removing this module disables tracing 
    and exposes the original commands again.
    
    .PARAMETER Tracefile
    The file to save captured data in JSON format

    .PARAMETER Module
    A powershell module to trace. All exported functions will be traced.

    .PARAMETER Command
    A list of commands to trace.
    #>
    [CmdletBinding(DefaultParameterSetName = "ByModule")]
    [OutputType([void])]

    param (
        [Parameter(ParameterSetName = "ByModule", Position = 0, Mandatory = $true)]
        [string]$Module,

        [Parameter(ParameterSetName = "ByCommand", Position = 0, Mandatory = $true)]
        [string[]]$Command,

        [Parameter(ParameterSetName = "ByModule", Position = 1, Mandatory = $true)]
        [Parameter(ParameterSetName = "ByCommand", Position = 1, Mandatory = $true)]
        [string]$TraceFile,

        [Parameter(ParameterSetName = 'Off', Mandatory = $true)]
        [switch]$Off
    )

    $ProxyModuleName = "PastaTracingProxy"
    Remove-Module $ProxyModuleName -ErrorAction SilentlyContinue

    switch ($PSCmdlet.ParameterSetName) {
    'ByModule'
        {
            [psmoduleinfo]$Module = Get-Module $Module
            [System.Management.Automation.CommandInfo[]]$Commands = $Module.ExportedCommands.Values | 
                foreach {$_}
        }
        'ByCommand'
        {
            [System.Management.Automation.CommandInfo[]]$Commands = Get-Command $Command
        }
        default
        {
            Write-Verbose "SutCommand tracing off" -Verbose
            return
        }
    }

    #requires -module Indented.StubCommand

    $BasePath = Split-Path $TraceFile
    if ([string]::IsNullOrWhiteSpace($BasePath)) {$BasePath = $PWD}
    $BasePath = Resolve-Path $BasePath
    if (-not (Test-Path $BasePath))
    {
        New-Item $BasePath -ItemType Directory -Force -ErrorAction Stop -Confirm:$Confirm
    }
    $TraceFile = Join-Path $BasePath (Split-Path $TraceFile -Leaf)


    $ClobberedModulePaths = New-Object System.Collections.ArrayList

    
    #Injected into each proxy command
    $FunctionBody = {

        $In = @{
            "InvocationInfo" = @{
                "$ProxiedCommandName" = $PSBoundParameters
            }
        }
        $In | ConvertTo-Json -Depth 10 | Out-File $TraceFile -Encoding utf8 -Append

        $InvocationResult = & $ProxiedCommandModule\$ProxiedCommandName @PSBoundParameters

        $Out = @{"Output" = $InvocationResult}
        $Out | ConvertTo-Json -Depth 10 | Out-File $TraceFile -Encoding utf8 -Append

        return $InvocationResult
    }


    #Stitch together a dynamic module definition
    $StubDef = New-Object System.Text.StringBuilder (10000 * $Commands.Count)
    foreach ($ProxiedCommand in $Commands)
    {
        $FunctionBody = [scriptblock]::Create((
            $FunctionBody.ToString() `
                -replace '\$ProxiedCommandModule', $ProxiedCommand.ModuleName `
                -replace '\$ProxiedCommandName', $ProxiedCommand.Name
        ))

        $null = $StubDef.AppendLine(
            (New-StubCommand -CommandInfo $ProxiedCommand -FunctionBody $FunctionBody)
        )

        $null = $ClobberedModulePaths.Add($ProxiedCommand.Module.ModuleBase)
    }
    $ModuleDef = [scriptblock]::Create($StubDef.ToString())


    #Import dynamic module
    $ProxyModule = New-Module -ScriptBlock $ModuleDef -Name $ProxyModuleName |
        Import-Module -PassThru -Force -Scope Global -ErrorAction Stop

    
    #Inject variable
    $ProxyModule.SessionState.PSVariable.Set('Tracefile', $Tracefile)

    
    #Cleanup - bring back the commands we masked on module unload
    $ClobberedModulePaths = $ClobberedModulePaths | select -Unique
    $ExportedCommandNames = $ProxyModule.ExportedCommands.Keys | foreach {$_}
    $ProxyModule.OnRemove = {Import-Module $ClobberedModulePaths -Scope Global}.GetNewClosure()


    #User feedback
    $Commands | where {$_.Name -notin $ExportedCommandNames} |
        foreach {Write-Warning "Not tracing command $_"}
    
    $ExportedCommandNames |
        foreach {Write-Verbose "Tracing command $_"}
    
    if ($ExportedCommandNames) {
        Write-Verbose "SutCommand tracing on" -Verbose
    }
    
}
