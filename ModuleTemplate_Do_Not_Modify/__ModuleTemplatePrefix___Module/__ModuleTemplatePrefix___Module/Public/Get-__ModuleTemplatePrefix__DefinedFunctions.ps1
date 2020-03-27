<#
.SYNOPSIS
Gets functions that are defined in a .ps1 file

.DESCRIPTION
Uses the Abstract Syntax Tree to parse a .ps1 file looking for root level functions.

.PARAMETER Path
The path to a .ps1 file

.EXAMPLE
Find all functions defined in all subfolders of current location

Get-ChildItem *.ps1 -Recurse | Get-__ModuleTemplatePrefix__DefinedFunctions

.NOTES
Author: Scott Crawford
#>

function Get-__ModuleTemplatePrefix__DefinedFunctions {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript( {
                if ((Test-Path -Path $_) -and ($_ -like '*.ps1')) {$true} else {
                    throw "The path '$_' is not an existing .ps1 file."
                }
            })]
        [alias('FullName')]
        [string[]]$Path
    )

    process {
        try {
            # Might want to search for an explanation somewhere else, but it parses the file and finds all function definitions.
            $file = Get-Item -Path $Path
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$null, [ref]$null)
            $allFunctions = $ast.FindAll( {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

            # Filter the functions to root level ones only.
            $rootFunctions = $allFunctions | Where-Object {-not $_.Parent.Parent.Parent}

            Write-Output $rootFunctions.Name

        } catch {
            Write-Error $Error[0]
        }
    }
}
