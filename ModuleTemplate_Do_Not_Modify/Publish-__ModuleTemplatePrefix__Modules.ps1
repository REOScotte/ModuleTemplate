[CmdletBinding()]

param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript( {
            if ($_.Exists) {$true} else {
                throw "The path '$_' does not exist."
            }
        })]
    [System.IO.DirectoryInfo]$Path
    ,
    # Used to completely rebuild the repository, signing and copying all files.
    [switch]$All
)

try {
    # Ensure the destination path is in PSModulePath since __ModuleTemplatePrefix___Module is there and will be needed
    # if ($env:PSModulePath.Split(';') -notcontains $Path) {$env:PSModulePath += ";$Path"}

    # Ignoring the above comments and importing __ModuleTemplatePrefix___Module directly from the working tree. This
    # prevents issues where a breaking change is introduced in __ModuleTemplatePrefix___Module and it can no longer be
    # imported to fix itself. Chickens, eggs, and paddleless creeks.
    Import-Module .\Modules\__ModuleTemplatePrefix___Module\__ModuleTemplatePrefix___Module -Force

    # Get [sic] the hash of the head commit and check for a prior successful build
    $headCommit = git rev-parse HEAD
    $currentFolder = "$((Get-Location).Path)\"
    $successfulBuildHashPath = '.\successfulBuild.txt'

    # Get the hash of the last successful build
    $lastBuildHash = Get-Content -Path successfulBuild.txt -ErrorAction SilentlyContinue

    if ($All -or -not $lastBuildHash) {
        $changedFiles = (Get-ChildItem -Path .\Modules -Recurse).Foreach( {$_.FullName.Replace($currentFolder, '')})

    } else {
        # Gets all files that have changed since the last successful build
        Write-Verbose "Getting changes between Last build of $lastBuildHash and Current head of $headCommit"
        $changedFiles = git diff --name-only $lastBuildHash $headCommit
    }

    Write-Verbose "Getting signing certificate"
    $signingCert = Get-__ModuleTemplatePrefix__CodeSigningCert

    Write-Verbose 'Getting the modules that have changed.'
    # The module folders start with __ModuleTemplatePrefix___, but may use forward '/' or backward '\' slashes because git.
    $modules = $changedFiles.Foreach( {$_.Split('\/')[0..1] -join '\'}).Where( {$_ -like "Modules\__ModuleTemplatePrefix___*"}) | Select-Object -Unique
    Write-Verbose "+----------------------+"
    Write-Verbose "| Modules that changed |"
    Write-Verbose "+----------------------+"
    foreach ($module in $modules) {Write-Verbose $module.Split('\')[1]}
    $__ModuleTemplateVariablePrefix__Modules = $modules | Get-__ModuleTemplatePrefix__Module

    foreach ($__ModuleTemplateVariablePrefix__Module in $__ModuleTemplateVariablePrefix__Modules) {
        # Sign all the scripts
        $scripts = Get-ChildItem -Path $__ModuleTemplateVariablePrefix__Module.modulePath -File -Include '*.ps1', '*.psd1', '*.psm1', '*.ps1xml' -Recurse

        foreach ($script in $scripts) {
            Set-__ModuleTemplatePrefix__AuthenticodeSignature -Path $script.FullName -Certificate $signingCert
        }

        # Sync the entire module to the repository
        # Robocopy has exit codes where 0-7 are all successful
        Write-Verbose "Copying $__ModuleTemplatePrefix__Module"
        $source = $__ModuleTemplateVariablePrefix__Module.ModulePath
        $destination = "$Path\$($__ModuleTemplateVariablePrefix__Module.Name)"
        robocopy $source $destination /mir
        if ($LASTEXITCODE -lt 8) {$LASTEXITCODE = 0} else {throw "robocopy failed"}

        $group = "Share_PowerShellModules_$($__ModuleTemplateVariablePrefix__Module.UserGroup)"
        Write-Verbose "Reseting permissions for $($__ModuleTemplateVariablePrefix__Module.Name)"
        icacls $destination /T /reset
        Write-Verbose "Granting permissions for $($__ModuleTemplateVariablePrefix__Module.Name) to $group"
        icacls $destination /grant "$($group):(OI)(CI)(RX)"
        if ($LASTEXITCODE -ne 0) {throw "icacls failed."}

    }

    # Delete modules that have been deleted from the git repository
    $publishedModules = Get-ChildItem -Path $Path
    foreach ($publishedModule in $publishedModules) {
        $moduleName = $publishedModule.Name
        if (-not (Test-Path -Path .\Modules\$moduleName)) {
            Write-Verbose "Removing deleted module $moduleName"
            Remove-Item $publishedModule.FullName -Recurse -Force
        }
    }

    Write-Verbose "Record the the hash of this build ($headCommit) for future comparison."
    Set-Content -Path $successfulBuildHashPath -Value $headCommit -Force

} catch {
    Write-Error $Error[0]
}
