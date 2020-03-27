$ModuleName = '__ModuleTemplatePrefix___Module'
$ModuleManifestName = '__ModuleTemplatePrefix___Module.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleName\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

