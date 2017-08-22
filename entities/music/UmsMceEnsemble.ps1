###############################################################################
#   Concrete entity class UmsMceEnsemble
#==============================================================================
#
#   This class describes a music ensemble entity, built from an 'ensemble'
#   XML element from the music namespace.
#
###############################################################################

class UmsMceEnsemble : UmsBaeItem
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

    [UmsMceInstrument[]] $Instruments

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMceEnsemble([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "ensemble")

        # Optional 'instruments' element (collection of 'instrument' elements)
        if ($XmlElement.instruments)
        {
            $this.BuildInstruments(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "instruments"))
        }
    }

    # Sub-constructor for the 'instruments' element
    [void] BuildInstruments([System.Xml.XmlElement] $InstrumentsElement)
    {
        $this.GetOneOrManyXmlElement(
            $InstrumentsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "instrument"
        ) | foreach {
                $this.Instruments += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

}