Use GenerateModuleTemplate.ps1 to create a new module development template.

The contents of ModuleTemplate should not be modified directly. The script will copy the contents and modify as needed based on the values given to the script.

The actual output of the script can be used to further modify a development template for new modules created for an organization.

The output of the script should be checked into source control and the actual powershell module inside should be published and used to create and manage modules.

Example

$params = @{
    Path = 'C:\Users\scott\OneDrive\Source\Repos\SC_Module'
    FullCOmpanyName = 'scottes.com'
    DomainName = 'scottes.com'
    ShortCompanyName = 'Scotte'
    Prefix = 'SC'
    Author = 'Scott Crawford'
}

C:\Users\scott\OneDrive\Source\Repos\ModuleTemplate\GenerateModuleTemplate.ps1 @params
