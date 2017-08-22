function ConvertTo-VorbisComment
{
    <#
    .SYNOPSIS
    Converts UMS metadata to Vorbis Comment.
    
    .DESCRIPTION
    This command converts UMS metadata to Vorbis Comments. The conversion process is complex and can't be reverted, as the resulting metadata will not fit the original entities one for one. This command support several types of input objects, but requires UmsDocument instances describing binding documents, with a umsa:albumTrackBinding binding element.

    .PARAMETER Uri
    A URI targeting a UMS document. The command will automatically create a UmsDocument instance from this URI before proceeding.

    .PARAMETER Document
    An instance of the UmsDocument class, as returned by the Get-UmsDocument command. This document must be a binding document, with a 'umsa:albumTrackBinding' binding element.
    
    .PARAMETER File
    An instance of the UmsFile class, as returned by the Get-UmsFile or Get-UmsManagedFile commands, with a Sidecar or Orphan cardinality and a umsa:albumTrackBinding binding element.

    .PARAMETER Source
    This parameters allows to select the source of UMS metadata. A 'raw' source will generate an entity tree from the main UMS document. A 'static' source will generate the same entity tree but from the static version of the UMS file, if available. A 'cache' source will use cached metadata, if available.

    .EXAMPLE
    Get-UmsFile -Path "D:\MyMusic" -Filter "track01*" | ConvertTo-VorbisComment
    #>

    [CmdletBinding(DefaultParametersetName='ByFileInstance')]
    Param(
        [Parameter(ParameterSetName='ByUriInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]  
        [ValidateNotNull()]
        [System.Uri] $Uri,

        [Parameter(ParametersetName='ByDocumentInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsDocument] $Document,

        [Parameter(ParametersetName='ByFileInstance',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

        [Parameter(ParametersetName='ByFileInstance')]
        [ValidateSet("Cache", "Static", "Raw")]
        [string] $Source = "Cache"
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands

        # Instantiate the constraint validator
        $Validator = [ConstraintValidator]::New(
            [ConfigurationStore]::GetHelperItem(
                "VorbisCommentConverter").Constraints)

        # Instantiate the converter
        $Converter = [VorbisCommentConverter]::New(
            [ConfigurationStore]::GetHelperItem(
                "VorbisCommentConverter").Options)
    }

    Process
    {
        # Parameter set abstraction.
        # Validate constraints against UmsFile or UmsDocument instances
        [UmsDocument] $_sourceDocument = $null        
        switch ($PSCmdlet.ParameterSetName)
        {
            "ByUriInstance"
            {
                # Try to get a document instance
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

                # Validate document constraints
                try
                {
                    $Validator.ValidateDocument($_sourceDocument)
                }
                catch
                {
                    # Validation failure
                    [EventLogger]::LogException($_.Exception)
                    [EventLogger]::LogError($Messages.ConstraintValidationFailure)
                    throw [UmsPublicCommandFailureException]::New(
                        "ConvertTo-VorbisComment")
                }
            }

            "ByDocumentInstance"
            {
                $_sourceDocument = $Document

                # Validate document constraints
                try
                {
                    $Validator.ValidateDocument($Document)
                }
                catch
                {
                    # Validation failure
                    [EventLogger]::LogException($_.Exception)
                    [EventLogger]::LogError($Messages.ConstraintValidationFailure)
                    throw [UmsPublicCommandFailureException]::New(
                        "ConvertTo-VorbisComment")
                }
            }

            "ByFileInstance"
            {
                # Validate file constraints
                try
                {
                    $Validator.ValidateFile($File)
                }
                catch
                {
                    # Validation failure
                    [EventLogger]::LogException($_.Exception)
                    [EventLogger]::LogError($Messages.ConstraintValidationFailure)
                    throw [UmsPublicCommandFailureException]::New(
                        "ConvertTo-VorbisComment")
                }

                # Process version
                switch ($Source)
                {
                    "Raw"
                    {
                        $_sourceDocument = $File.Document
                    }

                    "Static"
                    {
                        try
                        {
                            $_sourceDocument = $File.GetStaticDocument()
                        }
                        catch
                        {
                            [EventLogger]::LogInformation(
                                "No static version available.")
                            $_sourceDocument = $File.Document
                        }
                    }

                    "Cache"
                    {
                        [object] $_cachedMetadata = $null
                        try
                        {
                            $_cachedMetadata = $File.GetCachedMetadata()
                        }
                        catch
                        {
                            [EventLogger]::LogInformation(
                                "No cached metadata available.")
                            $_sourceDocument = $File.Document
                        }
                    }
                }
            }
        }

        # Get a live entity if no static metadata is available.
        [object] $_metadata = $null
        if ($_cachedMetadata)
        {
            $_metadata = $_cachedMetadata
        }
        else
        {
            try
            {
                $_metadata = Get-UmsEntity -Document $_sourceDocument
            }
            catch
            {
                # Entity instantiation failure.
                [EventLogger]::LogException($_.Exception)
                throw [UmsPublicCommandFailureException]::New(
                    "ConvertTo-VorbisComment")
            }
        }
        
        # Start metadata conversion
        try
        {
            $Converter.Convert($_metadata)
        }
        catch [VorbisCommentConverterException]
        {
            # Conversion failure
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.ConverterInvocationFailure)
            throw [UmsPublicCommandFailureException]::New(
                "ConvertTo-VorbisComment")
        }
        catch
        {
            # All other exceptions are also terminating
            [EventLogger]::LogException($_.Exception)
            throw [UmsPublicCommandFailureException]::New(
                "ConvertTo-VorbisComment")
        }        
    }
}