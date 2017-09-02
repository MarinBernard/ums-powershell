function Reset-UmsResourceCache
{
    <#
    .SYNOPSIS
    Resets the UMS resource cache statistics.
    
    .DESCRIPTION
    This command will reset the UMS resource cache statistics without flushing the cache.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [ResourceCache]::Reset()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Reset-UmsResourceCache")
        }
    }
}