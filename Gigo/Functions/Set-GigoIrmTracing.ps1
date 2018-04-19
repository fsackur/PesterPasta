function Set-GigoIrmTracing
{
    <#
    .SYNOPSIS
    Captures input and output of Invoke-RestMethod

    .DESCRIPTION
    When writing unit tests for API clients, it is very useful to pull real data that can be used for mocking. This
    function helps generate mock data. Simply run all the commands that you wish to write tests for and mock data is 
    traced in JSON format.

    This captures the input to the -Body parameter of, and the return from, Invoke-RestMethod.

    .EXAMPLE
    Set-GigoIrmTracing -On -UriFilter 'https://api.service.com/api/v2'
    Invoke-MyApiCall -Parameter1 $P1
    Invoke-MyApiCall -Parameter1 $P1
    Set-GigoIrmTracing -Off

    Captures inputs and outputs of REST method calls to api.service.com

    #>

    [CmdletBinding(DefaultParameterSetName = 'On', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param (
        [Parameter(ParameterSetName = 'On', Mandatory = $true, Position = 0)]
        [guid]$TraceId,

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
        if (Test-Path $FunctionPath)
        {
            Remove-Item $FunctionPath -Force
        }

        Write-Verbose "RestMethod tracing off" -Verbose
        return
    }

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
        Write-Verbose "$Uri matches $UriFilter. Tracing REST method"

        #Create object for trace DB
        $TraceEntrySplat = [ordered]@{
            TraceId         = $TraceId
            Command         = $MyInvocation.MyCommand.Name
            BoundParameters = $PSBoundParameters
            Result          = $null
            Error           = $null
        }

        try 
        {
            #Run the real query
            $Result = Microsoft.PowerShell.Utility\Invoke-RestMethod @PSBoundParameters
            $TraceEntrySplat.Result = $Result
            return $Result
        }
        catch
        {
            $TraceEntrySplat.Error = $_.Exception
            throw $_
        }
        finally
        {
            Add-GigoTraceEntry @TraceEntrySplat
        }
    }
    #This embeds the values of $TraceId and $UriFilter into the scriptblock
    $Closure = $FunctionDef.GetNewClosure()
    Set-Item Function:Global:$(Split-Path $FunctionPath -Leaf) $Closure
    Write-Verbose "RestMethod tracing on" -Verbose
}