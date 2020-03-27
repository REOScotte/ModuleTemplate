enum VersionStep {
    Major
    Minor
    Patch
}

enum UserGroup {
    All
    HelpDesk
    Systems
}

class __ModuleTemplatePrefix__ModuleInfo {
    [string]$Name
    [string]$Path
    [string]$ModulePath
    [string]$ManifestPath
    [hashtable]$Manifest
    [psmoduleinfo]$Module
    [UserGroup]$UserGroup
    hidden [string[]]$OldFingerprint
    hidden [string[]]$NewFingerprint

    __ModuleTemplatePrefix__ModuleInfo([string]$Name, [string]$Path) {
        $this.Name = $Name
        $this.Path = $Path
        $this.ModulePath = "$Path\$Name"
        $this.ManifestPath = "$($this.ModulePath)\$Name.psd1"

        $this.PopulateModule()
        $this.PopulateUserGroup()
        $this.PopulateOldFingerprint()
    }

    <#
    Reads the PSModuleInfo from the module folder and populates the Module property.
    Also, the old and new fingerprints are populated.
    #>
    hidden [void]PopulateModule() {
        $this.Manifest = Import-PowerShellDataFile -Path $this.ManifestPath -ErrorAction Stop

        $TempModule = Get-Module $this.ManifestPath -ListAvailable
        $this.Module = Import-Module $TempModule -PassThru -Force
    }

    <#
    Updates the OldFingerprint value to be prepare for using GetStep to get a new semantic version number.
    #>
    hidden [void]PopulateUserGroup() {
        $userGroupFile = Get-Content -Path "$($this.Path)\UserGroup.txt" -ErrorAction SilentlyContinue

        # If one could be read, use the first type as a default and commit it
        if ($userGroupFile) {
            $this.UserGroup = $userGroupFile
        }
    }

    <#
    Updates the OldFingerprint value to be prepare for using GetStep to get a new semantic version number.
    #>
    hidden [void]PopulateOldFingerprint() {
        $this.OldFingerprint = Get-Content -Path "$($this.Path)\fingerprint.txt" -ErrorAction SilentlyContinue
    }

    <#
    Imports the module contained within this __ModuleTemplatePrefix__Module
    #>
    [void]Import() {
        Import-Module $this.Module -Force -Scope Global
    }

    <#
    Removes the module contained within this __ModuleTemplatePrefix__Module from the current session
    #>
    [void]Remove() {
        Remove-Module $this.Module -Force
    }

    <#
    Updates the NewFingerprint value to be prepare for using GetStep to get a new semantic version number.
    The fingerprint is basically a list of all commands and associated parameters and aliases.
    This is borrowed heavily from https://powershellexplained.com/2017-10-14-Powershell-module-semantic-version/.
    #>
    hidden [void]PopulateNewFingerprint() {
        $commands = Get-Command -Module $this.Module

        Write-Verbose -Message 'Calculating fingerprint'
        $fingerprint = foreach ($command in $commands) {
            $command.Name
            foreach ($parameter in $command.Parameters.Keys) {
                '{0}:{1}' -f $command.Name, $command.Parameters[$parameter].Name
                $command.Parameters[$parameter].Aliases |
                    Foreach-Object {'{0}:{1}' -f $command.Name, $_}
            }
        }

        $this.NewFingerprint = $fingerprint

    }

    <#
    This looks for differences in the old and new fingerprints, looking for major or minor changes.

    A minor change is when a function or parameter of an existing function is added. This is minor because anything using
    a function will still work without modification. This can also occur if there is no prior fingerprint.
    This results in 'Minor' being output.

    A major change is when a function or parameter is deleted or when a parameter type changes. This is major because
    it could break existing code. This can also occur if there is no prior fingerprint.
    This results in 'Major' being output.

    If no major or minor changes are detected, 'Patch' is output.
    #>
    hidden [string] GetStep() {
        $this.PopulateNewFingerprint()

        if ($this.OldFingerprint) {
            $step = 'Patch'
            Write-Verbose -Message 'Detecting new features'
            $this.NewFingerprint | Where-Object {$_ -notin $this.OldFingerprint } |
                ForEach-Object {$step = 'Minor'; Write-Verbose -Message "  $_"}
            Write-Verbose -Message 'Detecting breaking changes'
            $this.OldFingerprint | Where-Object {$_ -notin $this.NewFingerprint } |
                ForEach-Object {$step = 'Major'; Write-Verbose -Message "  $_"}
        } else {
            Write-Verbose 'No existing fingerprint found so defaulting to Minor'
            $step = 'Minor'
        }

        return $step

    }

    <#
    Just a wrapper to get a parameter for UpdateVersion. If no step is specified, the fingerprints are analyzed.
    #>
    hidden [void]UpdateVersion() {
        $this.UpdateVersion($this.GetStep())
    }

    <#
    Updates the recorded version based on what Step is passed in. This allows manual stepping of the version number.
    #>
    [void]UpdateVersion([VersionStep]$Step) {
        $majorVersion = $this.Module.Version.Major
        $minorVersion = $this.Module.Version.Minor
        $patchVersion = $this.Module.Version.Build

        switch ($Step) {
            'Major' {$majorVersion++ ; $minorVersion = $patchVersion = 0 ; break}
            'Minor' {$minorVersion++ ; $patchVersion = 0 ; break}
            'Patch' {$patchVersion++ ; break}
        }
        $moduleVersionNew = (Get-Date -Format "$majorVersion.$minorVersion.$patchVersion.yyyyMMdd")

        $this.Manifest.ModuleVersion = $moduleVersionNew

    }

    <#
    Analyzes the module's folder structure to determine values to populate in the manifest for exported members.
    #>
    hidden [void]UpdateExportedMembers() {
        [string[]]$exportedFunctions = @()
        [string[]]$exportedCmdlets = @()
        [string[]]$exportedScripts = @()
        [string[]]$exportedVariables = @()
        [string[]]$exportedAliases = @()

        $publicPath = "$($this.ModulePath)\Public"
        $files = Get-ChildItem -Path $publicPath -Filter *.ps1 -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $functions = Get-__ModuleTemplatePrefix__DefinedFunctions -Path $file.FullName
            if ($functions) {
                $exportedFunctions += $functions
            }
        }

        #TODO: Create code to determine Cmdlets
        #TODO: Create code to determine Scripts
        #TODO: Create code to determine Variables
        #TODO: Create code to determine Aliases

        if ($exportedFunctions) {$this.Manifest.FunctionsToExport = $exportedFunctions}
        if ($exportedCmdlets) {$this.Manifest.CmdletsToExport = $exportedCmdlets}
        if ($exportedScripts) {$this.Manifest.ScriptsToProcess = $exportedScripts}
        if ($exportedVariables) {$this.Manifest.VariablesToExport = $exportedVariables}
        if ($exportedAliases) {$this.Manifest.AliasesToExport = $exportedAliases}

    }

    <#
    Updates a module by populating the manifest with a new version and corrected members.
    The fingerprint and UserGroup is also stored.
    Generally, this should be run before publishing to source control.

    Two commits are done because UpdateExportedMembers changes the the functions that are evaluated by PopulateNewFingerprint.
    #>
    [void]Update() {
        $this.UpdateExportedMembers()
        $this.Commit()
        $this.UpdateVersion()
        $this.Commit()
        $this.PopulateOldFingerprint()
    }

    <#
    Writes the changes back to disk. Update-ModuleManifest has a bug where it can't handle empty sets,
    so any key that doesn't have any values is removed before Update-ModuleManifest is called.
    Afterwards, the updated module is read back in.
    #>
    hidden [void]Commit() {
        $newManifest = $this.Manifest
        $keysToRemove = @()
        foreach ($key in $newManifest.Keys) {
            if ($newManifest.Item($key).Count -eq 0) {$keysToRemove += $key}
        }
        foreach ($key in $keysToRemove) {$newManifest.Remove($key)}

        Update-ModuleManifest -Path $this.ManifestPath @newManifest
        Set-Content -Path "$($this.Path)\UserGroup.txt" -Value $this.UserGroup
        Set-Content -Path "$($this.Path)\fingerprint.txt" -Value $this.NewFingerprint

        $this.PopulateModule()
    }
}
