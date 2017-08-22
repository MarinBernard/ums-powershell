function Get-UmsDocument
{
    <#
    .SYNOPSIS
    Retrieves and returns a UMS document as an XML document.
    
    .DESCRIPTION
    Retrieves and returns a UMS document as an XML document. This command queries the UMS document cache to speed-up document retrieval.

    .EXAMPLE
    Get-UmsDocument -Uri "http://ums.olivarim.com/catalogs/standard/cities/AR.ums"
    #>

    [CmdletBinding(DefaultParametersetName='ByUri')]
    Param(
        [Parameter(ParametersetName="ByItem",Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

        [Parameter(ParametersetName="ByUri",Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Uri] $Uri
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Abstract parameters
        switch ($PsCmdlet.ParameterSetName)
        {
            "ByItem"
            {
                $_uri = $File.Uri
            }
            "ByUri"
            {
                $_uri = $Uri
            }
        }

        # Try to get a UmsDocument instance
        [UmsDocument] $_document = $null
        try
        {
            $_document = [DocumentFactory]::GetDocument($_uri)
        }
        catch [DFResourceRetrievalFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.ResourceRetrievalFailure)
            throw [UmsPublicCommandFailureException]::New("Get-UmsDocument")
        }
        catch [DFCacheDocumentFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogWarning($Messages.DocumentCachingFailure)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.CommandFailure)
            throw [UmsPublicCommandFailureException]::New("Get-UmsDocument")
        }

        return $_document
    }
}