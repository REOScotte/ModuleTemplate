<#
.SYNOPSIS
Imports an __ModuleTemplatePrefix__Module into the current session

.DESCRIPTION
Imports the PowerShell module portion of an __ModuleTemplatePrefix__Module into the current session

.PARAMETER __ModuleTemplatePrefix__Module
The __ModuleTemplatePrefix__Module to imported

.PARAMETER Passthru
Specify whether to pass __ModuleTemplatePrefix__Module down the pipeline

.EXAMPLE
Get-__ModuleTemplatePrefix__Module .\__ModuleTemplatePrefix___Module | Import-__ModuleTemplatePrefix__Module

.NOTES
Author: Scott Crawford
#>

function Import-__ModuleTemplatePrefix__Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [__ModuleTemplatePrefix__ModuleInfo]$__ModuleTemplatePrefix__Module
        ,
        [switch]$Passthru = $false
    )

    process {
        try {
            $__ModuleTemplatePrefix__Module.Import()

            if ($Passthru) {
                Write-Output $__ModuleTemplatePrefix__Module
            }
        } catch {
            Write-Error $Error[0]
        }
    }
}
