function Remove-UmsFile
{
    <#
    .SYNOPSIS
    Deletes a UMS file.
    
    .DESCRIPTION
    This command deletes a UMS file and, optionaly, its linked content file. Although this command will also remove a UMS managed file, you should prefer the use of the Remove-UmsManagedFile to do so.
    
    .PARAMETER File
    An instance of the UmsFile class, as returned by the Get-UmsFile command.

    .PARAMETER WithContentFile
    If this parameter is specified, the command will also remove the content file linked to the UMS file, if it exists.

    .EXAMPLE
    Get-UmsFile -Path "MyFile.flac.ums" | Remove-UmsFile -WithContentFile
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
                $File.DeleteWithContentFile()
            }
            else
            {
                $File.Delete()
            }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.FileDeletionFailure)
            throw [UmsPublicCommandFailureException]::New("Remove-UmsFile")
        }
    }
}