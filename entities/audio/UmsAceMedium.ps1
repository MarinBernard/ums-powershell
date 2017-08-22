###############################################################################
#   Concrete entity class UmsAceMedium
#==============================================================================
#
#   This class describes an audio medium entity, built from a 'medium' XML
#   element from the audio namespace.
#
###############################################################################

class UmsAceMedium : UmsBaeMedium
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

    [UmsBaeTrack[]]     $Tracks                         # Audio or music tracks

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsAceMedium([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Verbose prefix
        $_verbosePrefix = "[UmsAceMedium]::UmsAceMedium(): "

        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Audio, "medium")
        
        # Mandatory 'tracks' element (collection of 'track' elements)
        $this.BuildTracks(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Audio, "tracks"))
    }

    # Sub-constructor for the 'tracks' element
    [void] BuildTracks([System.Xml.XmlElement] $TracksElement)
    {
        $this.GetOneOrManyXmlElement(
            $TracksElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "track"
        ) | foreach {
                $this.Tracks += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}