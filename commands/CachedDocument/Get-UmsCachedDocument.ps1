function Get-UmsCachedDocument
{
    <#
    .SYNOPSIS
    Returns the list of all cached UMS documents.
    
    .DESCRIPTION
    Returns the list of all cached UMS documents.
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param()

    Process
    {
        [CachedDocument[]] $_cachedDocuments = $null

        try
        {
            $_cachedDocuments + [DocumentCache]::Dump()
        }
        catch
        {
            throw [UmsPublicCommandFailureException]::New(
                "Get-UmsCachedDocument")
        }

        return $_cachedDocuments
    }
}