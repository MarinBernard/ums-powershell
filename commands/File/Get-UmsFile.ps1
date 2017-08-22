function Get-UmsFile
{
    <#
    .SYNOPSIS
    Retrieves and returns a UMS file.
    
    .DESCRIPTION
    Retrieves and returns a UmsFile instance from a file.

    .EXAMPLE
    Get-UmsFile -Path "MyFile.ums"
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [System.IO.FileInfo] $Path
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Give up now if the file does not exist
        if (-not $Path.Exists)
        {
            [EventLogger]::LogError($Messages.FileNotFound)
            throw [UmsPublicCommandFailureException]::New("Get-UmsFile")
        }

        # Try to get a UmsFile instance
        [UmsFile] $_file = $null
        
        try
        {
            $_file = [UmsFile]::New($Path)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Get-UmsFile")
        }

        return $_file
    }
}