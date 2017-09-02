###############################################################################
#   Class AudioAlbumArtworkConverter
#==============================================================================
#
#   This helper class offers methods to convert UMS metadata describing an
#   audio album track to a set of artwork pictures.
#
###############################################################################

class AudioAlbumPictureConverter : ForeignMetadataConverter
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    ###########################################################################
    # Constructors
    ###########################################################################

    # Default constructor. Initializes converter options.
    AudioAlbumPictureConverter([object[]] $Options) : base()
    {
        foreach ($_option in $Options)
        {
            # Optional features
            if ($_option.Name -like "feature-*")
            {
                $_label = $_option.Name.
                    Replace("feature-", "").
                    Replace("-", "")
                if ($this.Features.ContainsKey($_label))
                {
                    $this.Features[$_label] = $_option.Value
                }
            }
        }
    }

    ###########################################################################
    # Concrete implementations of [ForeignMetadataConverter] abstract methods
    #--------------------------------------------------------------------------
    #
    #   Method arguments are typeless since we may work on deserialized
    #   metadata, which do not allow static typing.
    #
    ###########################################################################

    # Main entry point. This method acts as a dispatch box, routing conversion
    # tasks to a more specific subconversion method.
    # Implements an abstract method from the [ForeignMetadataConverter] class.
    # Parameters:
    #   - $Metadata is either a UMS entity or a deserialized UMS entity.
    #       We use the generic object type as static typing is impossible in
    #       such a context.
    # Throws:
    #   - [FMCConversionFailureException] on conversion failure.
    [string[]] Convert([object] $Metadata)
    {
        [string[]] $_lines = @()

        switch ($Metadata.XmlNamespaceUri)
        {
            ([VorbisCommentConverter]::NamespaceUri).Audio
            {
                switch ($Metadata.XmlElementName)
                {
                    "albumTrackBinding"
                    {
                        $_lines += (
                            $this.ConvertUmsAbeAlbumTrackBinding($Metadata))
                    }

                    default
                    {
                        [EventLogger]::LogError($(
                            "The document element has the following " + `
                            "local name, which is not supported: {0}") `
                            -f $Metadata.XmlElementName)
                        throw [FMCConversionFailureException]::New()
                    }
                }
            }

            default
            {
                [EventLogger]::LogError($(
                    "The document element belongs to the following " + `
                    "namespace, which is not supported: {0}") `
                    -f $Metadata.XmlNamespaceUri)
                throw [FMCConversionFailureException]::New()
            }
        }

        return $_lines
    }

    ###########################################################################
    #   Subconverters
    #--------------------------------------------------------------------------
    #
    #   Method arguments are typeless since we may work on deserialized
    #   metadata, which do not allow static typing.
    #
    ###########################################################################
    # Converts an album track binding to Vorbis Comment.
    # Parameters:
    #   - $Metadata is either a UMS entity or a deserialized UMS entity.
    #       We use the generic object type as static typing is impossible in
    #       such a context.
    # Throws:
    #   - [FMCConversionFailureException] on conversion failure.

    [PSCustomObject[]] ConvertUmsAbeAlbumTrackBinding([object] $Metadata)
    {
        [PSCustomObject[]] $_pictures = @()

        $_album  = $Metadata.Album
        $_medium = $Metadata.Medium
        $_track  = $Metadata.Track

        try
        {
            $_lines += $this.RenderAlbumPictures($_album)
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMCConversionFailureException]::New()
        }

        return $_pictures
    }

    ###########################################################################
    #   Renderers
    #--------------------------------------------------------------------------
    #
    #   Renderers retrieve album pictures from specific UMS entities.
    #
    ###########################################################################

    # Retrieves pictures describing the album, such as the covers, media,
    # leaflets, booklets, etc.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [PSCustomObject[]] RenderAlbumPictures($AlbumMetadata, $TrackMetadata)
    {
        [PSCustomObject[]] $_pictures = @()

        try
        {
            
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderAlbumArtist")
        }

        return $_pictures
    }
}