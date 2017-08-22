function Clear-UmsDocumentCache
{
    <#
    .SYNOPSIS
    Removes all cached documents from the UMS document cache.
    
    .DESCRIPTION
    This command will flush the UMS document cache entirely. Cached documents will also be removed from the disk, if on-disk persistence is enabled.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [DocumentCache]::Flush()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Clear-UmsDocumentCache")
        } 
    }
}