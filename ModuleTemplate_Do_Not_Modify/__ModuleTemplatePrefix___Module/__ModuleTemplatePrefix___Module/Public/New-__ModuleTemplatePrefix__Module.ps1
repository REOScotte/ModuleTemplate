<#
.SYNOPSIS
Creates a blank module for __ModuleTemplateShortCompanyName__

.DESCRIPTION
Creates a module template with place holders for functions and test.

.PARAMETER Name
Name of the new module

.PARAMETER Author
Author of the new module

.PARAMETER CompanyName
Company that created the module

.PARAMETER ModuleVersion
Desired base module version

.PARAMETER Description
Describes the module

.PARAMETER PowerShellVersion
Requred PowerShell version

.EXAMPLE
New-__ModuleTemplatePrefix__Module -Name NewModule

.NOTES
Author: Scott Crawford
#>

function New-__ModuleTemplatePrefix__Module {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,
        [string]$Description = "__ModuleTemplateShortCompanyName__ $Name Module",
        [string]$Author = '__ModuleTemplateAuthor__',
        [string]$CompanyName = '__ModuleTemplateFullCompanyName__',
        [string]$PowerShellVersion = '5.1',
        [string]$ModuleVersion = (Get-Date -Format '0.0.0.yyyyMMdd'),
        [string]$TemplatePath = "$PSScriptRoot\..\Plaster\__ModuleTemplateShortCompanyName__DefaultModule"
    )

    process {
        try {
            # Ensure Name starts with capitalized __ModuleTemplatePrefix___. The length check prevents an error if there's less than 3 characters in the name
            if ($Name.Length -lt 3 -or $Name.Substring(0, 3) -ne '__ModuleTemplatePrefix___') {$Name = "__ModuleTemplatePrefix___$Name"}
            $Name = $Name -replace "^...", "__ModuleTemplatePrefix___"

            # Capture any output from Invoke-Plaster and redirect it to stream 6 so it doesn't interfere with the desired output.
            $informationStream = Invoke-Plaster -TemplatePath $TemplatePath -DestinationPath .\$Name -Name $Name -Description $Description -Author $Author -CompanyName $CompanyName -PowerShellVersion $PowerShellVersion -ModuleVersion $ModuleVersion
            Write-Information $informationStream

            # New manifests are created using '*' for various properties. These are replaced with the best practice of using @()
            $newManifestPath = ".\$Name\$Name\$Name.psd1"
            $manifestContent = Get-Content -Path $newManifestPath
            $updatedManifest = $manifestContent.Replace("'*'", "@()")
            Set-Content -Path $newManifestPath -Value $updatedManifest

            $__ModuleTemplateVariablePrefix__Module = Get-__ModuleTemplatePrefix__Module -Path .\$Name

            Write-Output $__ModuleTemplateVariablePrefix__Module
        } catch {
            Write-Error $Error[0]
        }
    }
}