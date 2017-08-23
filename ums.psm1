###############################################################################
# Include dependencies
###############################################################################

. "$PSScriptRoot\includes.ps1"

###############################################################################
# Module initialization
###############################################################################

# Initialize global variables
$global:ModuleRoot = $PSScriptRoot
$global:ModuleStrings = (
    Import-LocalizedData `
        -FileName "messages.psd1" `
        -BaseDirectory "$PSScriptRoot\messages")

# Initialize the configuration store
[ConfigurationStore]::LoadConfiguration("$PSScriptRoot\configuration.xml")

###############################################################################
# Initialize caching toolset
###############################################################################

# Initialize the document cache
[DocumentCache]::Initialize(
    (Join-Path -Path $env:LocalAppData -ChildPath "UMS\DocumentCache"))

###############################################################################
# Exports
###############################################################################

# *-ForeignMetadata
Export-ModuleMember -Function ConvertTo-ForeignMetadata
Export-ModuleMember -Function Update-ForeignMetadata

# *-UmsCachedDocument
Export-ModuleMember -Function Get-UmsCachedDocument
Export-ModuleMember -Function Remove-UmsCachedDocument

# *-UmsCachedEntity
Export-ModuleMember -Function Get-UmsCachedEntity

# *-UmsDocument
Export-ModuleMember -Function Get-UmsDocument

# *-UmsDocumentCache
Export-ModuleMember -Function Clear-UmsDocumentCache
Export-ModuleMember -Function Reset-UmsDocumentCache
Export-ModuleMember -Function Measure-UmsDocumentCache

# *-UmsEntity
Export-ModuleMember -Function Get-UmsEntity

# *-UmsEntityCache
Export-ModuleMember -Function Clear-UmsEntityCache
Export-ModuleMember -Function Measure-UmsEntityCache
Export-ModuleMember -Function Reset-UmsEntityCache

# *-UmsFile
Export-ModuleMember -Function Get-UmsFile
Export-ModuleMember -Function Rename-UmsFile
Export-ModuleMember -Function Remove-UmsFile

# *-UmsFileManagement
Export-ModuleMember -Function Disable-UmsFileManagement
Export-ModuleMember -Function Enable-UmsFileManagement
Export-ModuleMember -Function Test-UmsFileManagement

# *-UmsManagedFile
Export-ModuleMember -Function Get-UmsManagedFile
Export-ModuleMember -Function Remove-UmsManagedFile
Export-ModuleMember -Function Rename-UmsManagedFile
Export-ModuleMember -Function Update-UmsManagedFile