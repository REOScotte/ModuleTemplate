<#
.SYNOPSIS
Removes an __ModuleTemplatePrefix__Module from the current session

.DESCRIPTION
Removes the PowerShell module portion of an __ModuleTemplatePrefix__Module from the current session

.PARAMETER __ModuleTemplatePrefix__Module
The __ModuleTemplatePrefix__Module to removed

.PARAMETER Passthru
Specify whether to pass __ModuleTemplatePrefix__Module down the pipeline

.EXAMPLE
Get-__ModuleTemplatePrefix__Module .\__ModuleTemplatePrefix___Module | Remove-__ModuleTemplatePrefix__Module

.NOTES
Author: Scott Crawford
#>

function Remove-__ModuleTemplatePrefix__Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [__ModuleTemplatePrefix__ModuleInfo]$__ModuleTemplatePrefix__Module
        ,
        [switch]$Passthru = $false
    )

    process {
        try {
            $__ModuleTemplatePrefix__Module.Remove()

            if ($Passthru) {
                Write-Output $__ModuleTemplatePrefix__Module
            }

        } catch {
            Write-Error $Error[0]
        }
    }
}
