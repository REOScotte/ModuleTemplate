<#
.SYNOPSIS
Gets a handle to an __ModuleTemplateShortCompanyName__ Module

.DESCRIPTION
__ModuleTemplatePrefix__ Modules are a traditional PowerShell module, but are inside a folder of the same name.
This allows for keeping the tests and documentation with a module, without actually including
them in the code that's installed.

.PARAMETER Path
That path to the module. This can be either a short path to the root of the __ModuleTemplatePrefix__Module or
a long path to the actual deployable module.

.EXAMPLE
These both load the same module:

Get-__ModuleTemplatePrefix__Module .\PowerShell\__ModuleTemplatePrefix___ComputerLifecycle
Get-__ModuleTemplatePrefix__Module .\PowerShell\__ModuleTemplatePrefix___ComputerLifecycle\__ModuleTemplatePrefix___ComputerLifecycle

.NOTES
Author: Scott Crawford
#>

function Get-__ModuleTemplatePrefix__Module {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if (Test-Path -Path $_) {$true}
                else {throw "The path '$_' is not valid."}
            })]
        [alias('FullName')]
        [string[]]$Path
    )

    process {
        try {
            $filePath = Get-Item -Path $Path
            $moduleName = $filePath.Name
            if (-not $moduleName.StartsWith('__ModuleTemplatePrefix___')) {return Write-Verbose "Skipping $moduleName since it doesn't start with '__ModuleTemplatePrefix___'"}

            $fullName = $filePath.FullName
            $parent = $filePath.Parent.FullName
            $shortModule = "$fullName\$moduleName.psd1"
            $longModule = "$fullName\$moduleName\$moduleName.psd1"
            if (Test-Path $longModule) {
                $modulePath = $fullName
            } elseif (Test-Path $shortModule) {
                $modulePath = $parent
            } else {
                return Write-Warning "Module manifest not found for $moduleName"
            }

            $newModule = ([__ModuleTemplatePrefix__ModuleInfo]::New($moduleName, $modulePath))
            Write-Output $newModule

        } catch {
            Write-Error $Error[0]
        }
    }
}
