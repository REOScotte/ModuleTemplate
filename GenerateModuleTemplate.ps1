<#
.SYNOPSIS
This script creates a new module devlopment template.

.DESCRIPTION
Builds a custom module devolpment template based on the values provided.

The actual output of this command can be used to further modify a development template for new modules
created for an organization.

The output of this should be checked into source control and the actual powershell module inside
should be published and used to create and manage modules.

.PARAMETER Path
A non-existent path where the development template will be created

.PARAMETER FullCompanyName
The full company name, primarily used in copyright statements.

.PARAMETER DomainName 
The active directory domain where code-signing certs will be found. This will only
matter if the publishing script uses signing.

.PARAMETER ShortCompanyName
A short name used to refer to the company.

.PARAMETER Prefix
The prefix to use for module and command names. This should just be a couple letters.

.PARAMETER Author
This will become the default author of modules created.

.EXAMPLE
Create a new module development template in C:\Save\SC_Module

$params = @{
    Path = 'C:\Save\SC_Module'
    FullCompanyName = "Scotte's Company"
    DomainName = 'scottes.com'
    ShortCompanyName = 'Scotte'
    Prefix = 'SC'
    Author = 'Scott Crawford'
}

.\GenerateModuleTemplate.ps1 @params

.NOTES
Author: Scott Crawford
#>

[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$FullCompanyName,

    [Parameter(Mandatory)]
    [string]$DomainName,

    [Parameter(Mandatory)]
    [string]$ShortCompanyName,

    [Parameter(Mandatory)]
    [string]$Prefix,

    [Parameter(Mandatory)]
    [string]$Author
)

try {
    [string]$VariablePrefix = $Prefix.ToLower()
    [string]$ShortCompanyNameNoSpaces = $ShortCompanyName.Replace(' ', '')
    
    # Determine the path to the template that will be used. This should be in the parent of the current script.
    $scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent
    $templatePath = "$scriptPath\ModuleTemplate_Do_Not_Modify"

    # Since this script modifies contents of files, it's important to start with a clean folder.
    if (Test-Path $path) {throw "Destination path already exists. Please specify a new folder name."}
    
    # Copy the template to the new path
    Copy-Item -Path $templatePath\* -Recurse -Destination $path
    
    # Get handles for all files and folders. The $i loop essentially reverses the order since
    # recursion finds the files from the root down and folder names getting changed will break
    # deeper level renames.
    $files = Get-ChildItem -Path $path -Recurse
    $i = $files.Count - 1
    ($i..0) | ForEach-Object {
        $file = $files[$_]
        
        # The files will have their content modified to replace the template variables.
        if ($file -is [System.IO.FileInfo]) {
            $content = Get-Content -Path $file.FullName
            
            $content = $content -replace '__ModuleTemplateFullCompanyName__',          $FullCompanyName
            $content = $content -replace '__ModuleTemplateDomainName__',               $DomainName
            $content = $content -replace '__ModuleTemplateShortCompanyName__',         $ShortCompanyName
            $content = $content -replace '__ModuleTemplateShortCompanyNameNoSpaces__', $ShortCompanyNameNoSpaces
            $content = $content -replace '__ModuleTemplatePrefix__',                   $Prefix
            $content = $content -replace '__ModuleTemplateVariablePrefix__',           $VariablePrefix
            $content = $content -replace '__ModuleTemplateAuthor__',                   $Author
            $content = $content -replace '__ModuleTemplateYear__',                     ((Get-Date).Year)
            
            $content | Set-Content -Path $file.FullName
        }
        
        # Get a new name for the files/folders while replacing the template variables. Rename only if different.
        $newName = $file.Name.Replace('__ModuleTemplatePrefix__', $Prefix).Replace('__ModuleTemplateShortCompanyNameNoSpaces__', $ShortCompanyNameNoSpaces)
        if ($file.Name -ne $newName) {
            Rename-Item -Path $file.FullName -NewName $newName
        }
    }
} catch {
    throw $_
}
