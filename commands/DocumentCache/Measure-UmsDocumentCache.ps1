function Measure-UmsDocumentCache
{
    <#
    .SYNOPSIS
    Returns statistical data about the UMS document cache.
    
    .DESCRIPTION
    This command returns statistical data about the UMS document cache such as the number of cache hits, cache misses, or the cache hit ratio.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        [PSCustomObject] $Statistics = $null

        try
        {
            $_statistics = [DocumentCache]::GetStatistics()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Measure-UmsDocumentCache")
        }

        return $_statistics
    }
}