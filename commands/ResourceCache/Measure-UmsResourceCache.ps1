function Measure-UmsResourceCache
{
    <#
    .SYNOPSIS
    Returns statistical data about the UMS resource cache.
    
    .DESCRIPTION
    This command returns statistical data about the UMS resource cache such as the number of cache hits, cache misses, or the cache hit ratio.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        [PSCustomObject] $Statistics = $null

        try
        {
            $_statistics = [ResourceCache]::GetStatistics()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Measure-UmsResourceCache")
        }

        return $_statistics
    }
}