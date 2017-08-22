function Rename-UmsManagedFile
{
    <#
    .SYNOPSIS
    Renames a managed file in the UMS store.
    
    .DESCRIPTION
    This command renames all versions of a UMS file in the UMS store. If the file has a sidecar cardinality, the content file will also be renamed.
    
    .PARAMETER ManagedFile
    An instance of the UmsManagedFile class, as returned by the Get-UmsManagedFile command.

    .PARAMETER NewName
    The new name of the UMS file.

    .EXAMPLE
    Get-UmsManagedFile -Path "D:\MyMusic" -Filter "uselessFile" | Rename-UmsManagedFile -NewName "usefulFile"
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsManagedFile] $ManagedFile,

        [Parameter(Position=1,Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $NewName
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        try
        {
            $ManagedFile.Rename($NewName)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.FileRenameFailure)
            throw [UmsPublicCommandFailureException]::New(
                "Rename-UmsManagedFile")
        }
    }
}