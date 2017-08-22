function Measure-UmsEntityCache
{
    <#
    .SYNOPSIS
    Shows various statistics about the UMS entity cache.
    
    .DESCRIPTION
    Shows various statistics about the UMS entity cache.
    #>

    Process
    {
        [PSCustomObject] $_statistics = $null

        try
        {
            $_statistics = [EntityCache]::GetStatistics()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Measure-UmsEntityCache")
        }
    
        return $_statistics
    }
}