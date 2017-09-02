function Clear-UmsResourceCache
{
    <#
    .SYNOPSIS
    Removes all cached resources from the UMS resource cache.
    
    .DESCRIPTION
    This command will flush the UMS resource cache entirely.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [ResourceCache]::Flush()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Clear-UmsResourceCache")
        } 
    }
}