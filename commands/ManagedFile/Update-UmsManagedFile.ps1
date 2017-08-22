function Update-UmsManagedFile
{
    <#
    .SYNOPSIS
    Update the static and cached versions of a managed UMS file.
    
    .DESCRIPTION
    Update the static and cached versions of a managed UMS file. Static metadata are stored locally and consist of a single, static, consolidated and dependency-free UMS file. Most foreign metadata converters use cached versions as data sources, and expect them to be up-to-date.

    .PARAMETER ManagedFile
    A valid instance of the UmsManagedFile class. Use Get-UmsManagedFile to retrieve UmsManagedFile instances.

    .PARAMETER Version
    The type of version to update. Default is to update both static and cached versions, but this behaviour may be altered using this parameter.

    .PARAMETER Force
    Forces the update even if it is not necessary. Default behaviour is to skip the update unless the managed UMS file is newer than the version to update.
    
    .EXAMPLE
    Get-UmsManagedFile -Path "D:\MyMusic" -Cardinality Sidecar | Update-UmsManagedFile
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsManagedFile] $ManagedFile,

        [ValidateSet("All", "Static", "Cached")]
        [string] $Version = "All",

        [switch] $Force
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Update progress bar
        $_progressActivity = $("Updating UMS file " + $ManagedFile.Name + "...")
        Write-Progress `
            -Activity $_progressActivity `
            -CurrentOperation "Updating static version" `
            -PercentComplete 0

        # Update static version, if asked to
        if (@("All", "Static") -contains $Version)
        {
            # Check whether the update is needed
            if (
                ($ManagedFile.StaticVersion -eq 
                    [FileVersionStatus]::Current) -and
                (-not $Force.IsPresent))
            {
                [EventLogger]::LogInformation($Messages.StaticVersionUpToDate)
            }
            else
            {
                try
                {
                    $ManagedFile.UpdateStaticFile()
                }
                catch [UmsFileException]
                {
                    [EventLogger]::LogException($_.Exception)
                    [EventLogger]::LogError($Messages.StaticVersionUpdateFailure)
                }
            }
        }

        # Update progress bar
        Write-Progress `
            -Activity $_progressActivity `
            -CurrentOperation "Updating cached version" `
            -PercentComplete 50

        # Update cached version, if asked to
        if (@("All", "Cached") -contains $Version)
        {
            # Check whether the update is needed
            if (
                ($ManagedFile.CachedVersion -eq
                    [FileVersionStatus]::Current) -and
                (-not $Force.IsPresent))
            {
                [EventLogger]::LogInformation($Messages.CachedVersionUpToDate)
            }
            else
            {
                # Retrieve the UMS entity
                # Tags:
                #   - PublicCommandInvocation
                [UmsAeEntity] $_entity = $null
                try
                {
                    $_entity = Get-UmsEntity -File $ManagedFile -Source Raw
                }
                catch
                {
                    [EventLogger]::LogException($_.Exception)
                    throw [UmsPublicCommandFailureException]::New("Update-UmsManagedFile")
                }
            
                # Update cache file
                try
                {
                     $ManagedFile.UpdateCachedMetadata($_entity)
                }
                catch
                {
                    [EventLogger]::LogException($_.Exception)
                    throw [UmsPublicCommandFailureException]::New("Update-UmsManagedFile")
                }
            }
        }

        # Update progress bar
        Write-Progress `
            -Activity $_progressActivity `
            -Completed
    }
}