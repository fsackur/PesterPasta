

<#
    .Synopsis
    Capture input and output of Invoke-RestMethod to a trace file

#>

[CmdletBinding(DefaultParameterSetName='On', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
[OutputType([void])]
param (
    [Parameter(ParameterSetName='On', Position=0, Mandatory=$true)]
    [string]$TraceFile,

    [Parameter(ParameterSetName='On')]
    [switch]$On,

    [Parameter(ParameterSetName='On')]
    [switch]$Force,

    [Parameter(ParameterSetName='Off', Mandatory=$true)]
    [switch]$Off
)

$FunctionPath = "Function:\Invoke-RestMethod"

if ($PSCmdlet.ParameterSetName -eq 'Off')
{
    if (Test-Path $FunctionPath)
    {
        Remove-Item $FunctionPath -Force
    }
    return
}

$BasePath = Split-Path $TraceFile
if (-not (Test-Path $BasePath))
{
    #if ($PSCmdlet.ShouldProcess($BasePath))
    #{
        New-Item $BasePath -ItemType Directory -Force -ErrorAction Stop -Confirm:$Confirm
    #}
}


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

    if ($Body.GetType().IsPrimitive -or $Body -is [string])
    {
        $Input = $Body
    }
    else
    {
        $Input = ConvertTo-Json $Body
    }

    if (-not $TraceFile) {throw "Closure not created properly"}
    $BasePath = Split-Path $TraceFile
    if (-not (Test-Path $BasePath))
    {
        New-Item $BasePath -ItemType Directory -Force -ErrorAction Stop -Confirm:$Confirm
    }
    if (-not (Test-Path $TraceFile)) {$null | Out-File $TraceFile -Encoding utf8}

    $Input | Out-File $TraceFile -Append utf8
    '=' |  Out-File $TraceFile -Append utf8
    $Output = Microsoft.PowerShell.Utility\Invoke-RestMethod @PSBoundParameters
    $Output | Out-File $TraceFile -Append utf8

}

#This embeds the value of $TraceFile into the scriptblock
$Closure = $FunctionDef.GetNewClosure()
Set-Item Function:Global:$(Split-Path $FunctionPath -Leaf) $Closure