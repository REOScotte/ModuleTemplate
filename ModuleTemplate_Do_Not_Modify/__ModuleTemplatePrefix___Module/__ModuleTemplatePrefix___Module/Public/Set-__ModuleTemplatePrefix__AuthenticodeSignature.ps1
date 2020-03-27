<#
.SYNOPSIS
Signs a script with an authenticode signature

.DESCRIPTION
Uses a specified certificate to sign a script file. A signature needs to have a timestamp certificate as well
so it keeps working past the expiration of the certificate used. To that end, there are a few timestamp servers
pre-defined, but a specific server can be specified if desired.

In any case, the timestamp server certificate will be included in the authenticode signature or an error is thrown.

.PARAMETER Path
The path to the file to be signed

.PARAMETER Certificate
The certificate used to sign the script

.PARAMETER TimeStampServer
The timestamp server used to validate the date and time a script was signed.

.EXAMPLE
Get a code signing certificate from __ModuleTemplateShortCompanyName__ certificate store and use it to sign TestScript.ps1
Set-__ModuleTemplatePrefix__AuthenticodeSignature -Path TestScript.ps1 -Certificate (Get-__ModuleTemplatePrefix__CodeSigningCert)

.NOTES
Author: Scott Crawford
#>

function Set-__ModuleTemplatePrefix__AuthenticodeSignature {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TimeStampServer
    )

    begin {
        $timeStampers = @(
            'http://timestamp.digicert.com'
            'http://timestamp.verisign.com/scripts/timstamp.dll'
        )
    }

    process {
        try {
            # If a timestamp server is specied, use it, otherwise try each of the pre-defined ones
            if ($TimeStampServer) {
                Write-Verbose "Setting authenticode signature with timestamp server '$TimeStampServer'."
                $authenticodeSignature = Set-AuthenticodeSignature -FilePath $Path -Certificate $Certificate -TimestampServer $TimeStampServer -Force

            } else {
                foreach ($timeStamper in $timeStampers) {
                    Write-Verbose "Setting authenticode signature with timestamp server '$timeStamper'."
                    $authenticodeSignature = Set-AuthenticodeSignature -FilePath $Path -Certificate $Certificate -TimestampServer $timeStamper -Force
                    if ($authenticodeSignature.TimeStamperCertificate) {break}
                }
            }

            # If the the authenticode signature doesn't have a timestamper certificate, something went wrong
            if (-not $authenticodeSignature.TimeStamperCertificate) {
                throw "The 'TimeStamperCertificate' property is empty."
            }

            Write-Output $authenticodeSignature

        } catch {
            Write-Error $Error[0]
        }
    }
}
