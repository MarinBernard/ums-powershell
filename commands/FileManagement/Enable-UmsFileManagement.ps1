function Enable-UmsFileManagement
{
    <#
    .SYNOPSIS
    Enables UMS file management for the specified folder.
    
    .DESCRIPTION
    This function creates the local folder structure which is needed to manage UMS files.
    
    .PARAMETER Path
    A path to a valid folder. Default is the current folder.
    
    .EXAMPLE
    Enable-UmsFileManagement -Path "D:\MyMusic"
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,ValueFromPipeline=$true)]
        [System.IO.DirectoryInfo] $Path
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Use local path if no path was specified
        if ($Path -eq $null) { $Path = Get-Item -Path "." }

         # Test management
        [bool] $_managementIsEnabled = $null
    
        try
        {
            $_managementIsEnabled = [FileManager]::TestManagement($Path)
        }
        # Catch any exception and abort.
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogWarning($Messages.InconsistentState)
            [EventLogger]::LogWarning($Messages.RunCommandAdvice `
                -f "Test-UmsItemManagement")
            throw [UmsPublicCommandFailureException]::New(
                "Enable-UmsFileManagement")        }

        # We only disable management if it is enabled.
        if ($_managementIsEnabled)
        {
            [EventLogger]::LogWarning($Messages.ManagementEnabled)
            return
        }

        # Enable UMS item management
        try
        {
            [FileManager]::EnableManagement($Path)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.EnableManagementFailure)
            throw [UmsPublicCommandFailureException]::New(
                "Enable-UmsFileManagement")  
        }

        [EventLogger]::LogInformation($Messages.EnableManagementSuccess)
    }   
}