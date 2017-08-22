function Rename-UmsFile
{
    <#
    .SYNOPSIS
    Renames a UMS file and its content file.
    
    .DESCRIPTION
    This command renames a UMS file. If the file has a sidecar cardinality, the content file will also be renamed. Although this commands will also rename managed files, you should prefer the use of the Rename-UmsManagedFile command.
    
    .PARAMETER File
    An instance of the UmsFile class, as returned by the Get-UmsFile command.

    .PARAMETER NewName
    The new name of the UMS file.

    .EXAMPLE
    Get-UmsFile -Path "OldName.flac.ums" | Rename-UmsFile -NewName "NewName.flac"
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

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
        [UmsFile] $_newFile = $null
        
        try
        {
            $_newFile = $File.Rename($NewName)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.FileRenameFailure)
            throw [UmsPublicCommandFailureException]::New("Rename-UmsFile")
        }

        return $_newFile
    }
}