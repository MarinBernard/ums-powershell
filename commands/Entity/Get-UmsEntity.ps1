function Get-UmsEntity
{
    <#
    .SYNOPSIS
    Reads and returns a UMS entity from a UMS file, document or from a URI.
    
    .DESCRIPTION
    This command parses the XML document stored in a UMS file, and returns entity hierarchy describing the UMS metadata.

    .PARAMETER Uri
    Absolute URI to one or several UMS documents.

    .PARAMETER Document
    A UmsDocument instance, as returned by the Get-UmsDocument command.

    .PARAMETER File
    A UmsFile instance, as returned by the Get-UmsFile and Get-UmsManagedFile commands.

    .PARAMETER Source
    Allows to select the source to use to build metadata. This parameter is only available when input objects are UmsManagedFile instances. The default value of this parameter is "Cache", and will make the command return cached metadata, if available. If cached metadata are unavailable, the command will fallback to the static version of the UMS document, provided it is up-to-date. Finally, it will use raw metadata rendering if no other source is available. Unmanaged UMS files do not support static or cached versions and always use raw rendering.
    
    .EXAMPLE
    Get-UmsEntity -Path "D:\MyMusic\album.ums"
    #>

    [CmdletBinding(DefaultParametersetName='None')]
    Param(
        [Parameter(ParameterSetName='ByUriInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]  
        [ValidateNotNull()]
        [System.Uri] $Uri,

        [Parameter(ParameterSetName='ByDocumentInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsDocument] $Document,

        [Parameter(ParameterSetName='ByFileInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

        [Parameter(ParameterSetName='ByFileInstance')]
        [ValidateSet("Cache", "Static", "Raw")]
        [string] $Source = "Cache"
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands
    }

    Process
    {
        # Parameter set abstraction.
        # The command requires a UmsDocument instance.
        [UmsDocument] $_sourceDocument = $null
        switch ($PSCmdlet.ParameterSetName)
        {
            # If a URI is supplied, we need to instantiate a UmsDocument
            # instance from it.
            "ByUriInstance"
            {
                try
                {
                    $_sourceDocument = Get-UmsDocument -Uri $Uri
                }
                catch
                {
                    [EventLogger]::LogException($_.Exception)
                    [EventLogger]::LogError($Messages.GetDocumentByURIFailure)
                    throw [UmsPublicCommandFailureException]::New(
                        "Get-UmsEntity")
                }
            }

            # If a UmsDocument is given, use it.
            "ByDocumentInstance"
            {
                $_sourceDocument = $Document
            }

            # If a UmsFile is given, use its internal UmsDocument instance.
            "ByFileInstance"
            {
                switch ($Source)
                {
                    # If Source is "Raw", we use the UmsDocument instance from
                    # the UmsFile instance.
                    "Raw"
                    {
                        $_sourceDocument = $File.Document
                    }

                    # If source is "Static", we need to instantiate a new
                    # UmsDocument from a the static version.
                    "Static"
                    {
                        # The use of the "Static" value is not allowed if the
                        # UmsFile instance is not a UmsManagedFile instance.
                        if ($File.GetType().FullName -ne "UmsManagedFile")
                        {
                            [EventLogger]::LogError(
                                $Messages.ManagedFileRequired)
                            throw [UmsPublicCommandFailureException]::New(
                                "Get-UmsEntity")  
                        }

                        try
                        {
                            $_sourceDocument = $File.GetStaticDocument()
                        }
                        catch
                        {
                            [EventLogger]::LogException($_.Exception)
                            throw [UmsPublicCommandFailureException]::New(
                                "Get-UmsEntity")   
                        }
                    }
                    
                    "Cache"
                    {
                        # The use of the "Cache" value is not allowed if the
                        # UmsFile instance is not a UmsManagedFile instance.
                        if ($File.GetType().FullName -ne "UmsManagedFile")
                        {
                            [EventLogger]::LogError(
                                $Messages.ManagedFileRequired)
                            throw [UmsPublicCommandFailureException]::New(
                                "Get-UmsEntity")  
                        }

                        # Try to get and return cached metadata
                        [PSObject] $_metadata = $null
                        try
                        {
                            $_metadata = $File.GetCachedMetadata()
                        }
                        catch
                        {
                            [EventLogger]::LogException($_.Exception)
                            throw [UmsPublicCommandFailureException]::New(
                                "Get-UmsEntity")   
                        }

                        # Return deserialized metadata
                        return $_metadata
                    }
                }
            }
        }

        # Try to build the entity
        [UmsAeEntity] $_entity = $null

        try
        {
            $_entity = [EntityFactory]::ProcessDocument(
                $_sourceDocument,
                $_sourceDocument.SourceUri.AbsoluteUri)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.EntityGenerationFailure)
            throw [UmsPublicCommandFailureException]::New(
                "Get-UmsEntity")  
        }

        return $_entity
    }
}