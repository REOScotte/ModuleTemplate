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

[string]$VariablePrefix = $Prefix.ToLower()



Copy-Item -Recurse

$files = Get-ChildItem -Exclude .\New-ModuleTemplate.ps1 -Recurse
$i = $files.Count - 1
($i..0) | ForEach-Object {
    $file = $files[$_]
    
    $content = Get-Content -Path $file.FullName

    $content = $content -replace '__ModuleTemplateFullCompanyName__',  $FullCompanyName
    $content = $content -replace '__ModuleTemplateDomainName__',       $DomainName
    $content = $content -replace '__ModuleTemplateShortCompanyName__', $ShortCompanyName
    $content = $content -replace '__ModuleTemplatePrefix__',           $Prefix
    $content = $content -replace '__ModuleTemplateVariablePrefix__',   $VariablePrefix
    $content = $content -replace '__ModuleTemplateAuthor__',           $Author

    $content | Set-Content -Path $file.FullName
    
    $newName = $file.Name.Replace('__ModuleTemplatePrefix__', $TemplatePrefix)
    Rename-Item -Path $file.FullName -NewName $newName
}
