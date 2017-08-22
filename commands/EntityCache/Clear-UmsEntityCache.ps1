function Clear-UmsEntityCache
{
    <#
    .SYNOPSIS
    Removes all cached instances from the UMS entity cache.
    
    .DESCRIPTION
    This command will flush the UMS entity cache entirely.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        try
        {
            [EntityCache]::Flush()
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New("Clear-UmsEntityCache")
        }
    }
}