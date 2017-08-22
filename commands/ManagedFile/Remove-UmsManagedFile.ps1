function Remove-UmsManagedFile
{
    <#
    .SYNOPSIS
    Removes a managed file from the UMS store.
    
    .DESCRIPTION
    This command removes all versions of a managed file from the UMS store.
    
    .PARAMETER ManagedFile
    An instance of the UmsManagedFile class, as returned by the Get-UmsManagedFile command.

    .PARAMETER WithContentFile
    If this parameter is specified, the command will also remove the content file linked to the UMS file, if it exists.

    .EXAMPLE
    Get-UmsManagedFile -Path "D:\MyMusic" -Filter "uselessFile" | Remove-UmsManagedFile
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsManagedFile] $ManagedFile,

        [switch] $WithContentFile
    )
    
    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Remove the managed file
        try
        {
            if ($WithContentFile.IsPresent)
            {
                $ManagedFile.DeleteWithContentFile()
            }
            else
            {
                $ManagedFile.Delete()
            }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.FileDeletionFailure)
            throw [UmsPublicCommandFailureException]::New(
                "Remove-UmsManagedFile")
        }
    }
}