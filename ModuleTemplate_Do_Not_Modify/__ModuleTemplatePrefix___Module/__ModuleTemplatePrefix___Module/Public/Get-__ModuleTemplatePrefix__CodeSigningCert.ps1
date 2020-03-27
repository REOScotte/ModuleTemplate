<#
.SYNOPSIS
Gets a current __ModuleTemplateShortCompanyName__ Code Signing certificate

.DESCRIPTION
Queries the local certificate store for code signing certificates issued by the specified domain. The certificate with the
most distant validity is returned.

If a certificate doesn't currently exist, a request is made for one using the specified template and that certificate
is returned.

.PARAMETER Domain
The source domain to search for

.PARAMETER TemplateName
The desired template for a new certificate

.EXAMPLE
Search for a certificate issued by __ModuleTemplateDomainName__ and if one isn't found, request one with the __ModuleTemplateShortCompanyName__CodeSigning template

Get-__ModuleTemplatePrefix__CodeSigningCert -Domain __ModuleTemplateDomainName__ -TemplateName __ModuleTemplateShortCompanyName__CodeSigning

.NOTES
Author: Scott Crawford
#>

function Get-__ModuleTemplatePrefix__CodeSigningCert {
    [CmdletBinding()]

    param (
        [string]$Domain = '__ModuleTemplateDomainName__',
        [string]$TemplateName = '__ModuleTemplateShortCompanyName__CodeSigning'
    )

    try {
        # Assemble the issuer string from the parts of Domain. Desired output is this form: '*, DC=domain, DC=com'
        $domainParts = $Domain.split('.')
        $issuer = '*'
        foreach ($domainPart in $domainParts) {$issuer += ", DC=$domainPart"}
        Write-Verbose "Issuer: $issuer"

        # Get current certificates from the issuer, sort them by the longest lasting, and pick the first in the list
        $date = Get-Date
        $cert = (Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert).Where({
                $_.Issuer -like $issuer -and
                $_.NotAfter -ge $date -and
                $_.NotBefore -le $date
            }) | Sort-Object NotAfter -Descending | Select-Object -First 1

        if ($cert) {
            Write-Verbose "Found certificate $($cert.Thumbprint)"
            
        } else {
            Write-Verbose "Requesting new certificate"
            $cert = (Get-Certificate -Template $TemplateName -CertStoreLocation Cert:\CurrentUser\My).Certificate
        }

        if ($cert) {
            Write-Verbose "Get certificate $($cert.Thumbprint)"

        } else {
            throw 'No certificate found'
        }

        Write-Output $cert

    } catch {
        Write-Error $Error[0]
    }
}