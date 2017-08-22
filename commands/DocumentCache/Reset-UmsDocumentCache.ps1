function Reset-UmsDocumentCache
{
    <#
    .SYNOPSIS
    Resets the UMS document cache statistics.
    
    .DESCRIPTION
    This command will reset the UMS document cache statistics without flushing the cache.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [DocumentCache]::Reset()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Reset-UmsDocumentCache")
        }
    }
}