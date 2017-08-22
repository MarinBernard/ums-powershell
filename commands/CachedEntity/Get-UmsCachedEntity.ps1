function Get-UmsCachedEntity
{
    <#
    .SYNOPSIS
    Returns the list of all cached UMS entities.
    
    .DESCRIPTION
    Returns the list of all cached UMS entities.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        [UmsCachedEntity[]] $_cachedEntities = $null
        
        try
        {
            $_cachedEntities = [EntityCache]::Dump()
        }
        catch
        {
            throw [UmsPublicCommandFailureException]::New(
                "Get-UmsCachedEntity")
        }

        return $_cachedEntities
    }
}