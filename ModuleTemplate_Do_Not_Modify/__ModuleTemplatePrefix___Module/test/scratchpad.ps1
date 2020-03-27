<#
This is needed during development of __ModuleTemplatePrefix___Module. Since it's own functions may be
modified, this copies the current state elsewhere and imports that version,
leaving you free to modify the "real" version. Powershell should be reset and
these command run after every modification. Especially to the class file.
#>
Set-Location C:\Users\scott\OneDrive\Source\Repos\Systems.PowerShell\Modules
robocopy .\__ModuleTemplatePrefix___Module\__ModuleTemplatePrefix___Module C:\Save\__ModuleTemplatePrefix___Module /mir
Import-Module C:\Save\__ModuleTemplatePrefix___Module -Force
$mod = Get-__ModuleTemplatePrefix__Module __ModuleTemplatePrefix___Module
[__ModuleTemplatePrefix__ModuleInfo]::New('__ModuleTemplatePrefix___Module', '.\__ModuleTemplatePrefix___Module')

$mod | Update-__ModuleTemplatePrefix__Module -Verbose
$mod.Commit()
$mod.PopulateExportedMembers()
$mod.PopulateModule()
$mod.Update()
$mod | Update-__ModuleTemplatePrefix__Module -Verbose
Update-__ModuleTemplatePrefix__Module $mod
$mod.Module.Version

<# The rest of this is just random testing stuff.
$mod.GetStep()

$mod = Get-__ModuleTemplatePrefix__Module .\__ModuleTemplatePrefix___ComputerLifecycle
#$mods = 'a'
#$mods = dir |  Get-__ModuleTemplatePrefix__Module #-Verbose
$mods | Get-__ModuleTemplatePrefix__ModuleFingerprint
$mods | Get-__ModuleTemplatePrefix__ModuleExportedMembers
#$mod.Module|select *

# Update the manifest for all changed modules
$exportedMembers = Get-__ModuleTemplatePrefix__ModuleExportedMembers -Module $mod.Module
Update-ModuleManifest @exportedMembers -Path $mod.Module.Path

$mod.Module.ExportedCommands

$mod = Get-__ModuleTemplatePrefix__Module .\__ModuleTemplatePrefix___ComputerLifecycle
Get-__ModuleTemplatePrefix__ModuleBumpVersionType -__ModuleTemplatePrefix__Module $mod -Verbose |
    Step-__ModuleTemplatePrefix__Module $mod
#>

        $newManifest = Import-PowerShellDataFile -Path .\__ModuleTemplatePrefix___Module\__ModuleTemplatePrefix___Module\__ModuleTemplatePrefix___Module.psd1
        $keysToRemove = @()
        foreach ($key in $newManifest.Keys) {
            if ($newManifest.Item($key).Count -eq 0) {$keysToRemove += $key}
        }
        foreach ($key in $keysToRemove) {$newManifest.Remove($key)}

        #Update-ModuleManifest -Path $this.ManifestPath @newManifest
        return $keysToRemove


        $mod = Nenw-__ModuleTemplatePrefix__Module TestMod
        $oldName = "$($mod.ModulePath)\old.psd1"
        Rename-Item $mod.ManifestPath $oldName
        $filecontent = Get-Content -Path $oldName
        $newcontent = $filecontent.Replace("'*'", "@()")
        Set-Content -Path $mod.ManifestPath -Value $newcontent
        fc.exe $oldName $mod.ManifestPath