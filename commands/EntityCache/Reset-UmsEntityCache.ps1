function Reset-UmsEntityCache
{
    <#
    .SYNOPSIS
    Resets the UMS entity cache statistics.
    
    .DESCRIPTION
    This command will reset the UMS entity cache statistics without flushing the cache.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [EntityCache]::Reset()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Reset-UmsEntityCache")
        }    }
}