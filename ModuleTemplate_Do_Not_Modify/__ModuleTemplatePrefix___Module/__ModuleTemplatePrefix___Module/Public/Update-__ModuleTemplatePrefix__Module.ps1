<#
.SYNOPSIS
Updates version and export information for an __ModuleTemplatePrefix__ Module

.DESCRIPTION
Uses the .Update() method of __ModuleTemplatePrefix__Module to update version and export information in the manifest.
Sometimes the manifest file is locked while editing, so this will retry up to 10 times.

.PARAMETER __ModuleTemplatePrefix__Module
The __ModuleTemplatePrefix__Module to updated

.PARAMETER UserGroup
Specifies the UserGroup property of an __ModuleTemplatePrefix__Module so Publish-__ModuleTemplatePrefix__Module.ps1 knows which group to give permissions to.

This value is stored in UserGroup.txt in the root of the __ModuleTemplatePrefix__Module.

.PARAMETER Step
A step type to increment the version of the __ModuleTemplatePrefix__Module

.PARAMETER RetryCount
A counter to eventually fail out of repeated calls to the command during errors.

.PARAMETER Passthru
Specify whether to pass __ModuleTemplatePrefix__Module down the pipeline

.EXAMPLE
Get-__ModuleTemplatePrefix__Module .\__ModuleTemplatePrefix___Module | Update-__ModuleTemplatePrefix__Module

.NOTES
Author: Scott Crawford
#>

function Update-__ModuleTemplatePrefix__Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [__ModuleTemplatePrefix__ModuleInfo]$__ModuleTemplatePrefix__Module
        ,
        [UserGroup]$UserGroup
        ,
        [VersionStep]$Step
        ,
        [switch]$Passthru = $false
        ,
        [int]$RetryCount = 1
    )

    process {
        try {
            # Only update version or user group if they're specified.
            if ($PSBoundParameters.ContainsKey('UserGroup')) {$__ModuleTemplatePrefix__Module.UserGroup = $UserGroup}
            if ($PSBoundParameters.ContainsKey('Step')) {$__ModuleTemplatePrefix__Module.UpdateVersion([VersionStep]$Step)}

            Write-Verbose "This is attempt number $RetryCount"
            $__ModuleTemplatePrefix__Module.Update()

            if ($Passthru) {
                Write-Output $__ModuleTemplatePrefix__Module
            }

        } catch {
            if ($RetryCount -lt 10) {
                Start-Sleep -Seconds 1
                $RetryCount++
                # Remove the bound copy of RetryCount so we can pass the incremented version
                if ($PSBoundParameters.ContainsKey('RetryCount')) {$PSBoundParameters.Remove('RetryCount')}
                Update-__ModuleTemplatePrefix__Module @PSBoundParameters -RetryCount $RetryCount
            } else {
                Write-Verbose "Failing after $RetryCount tries."
                Write-Error $Error[0]
            }
        }
    }
}
