###############################################################################
#   Concrete entity class UmsMceInstrumentalist
#==============================================================================
#
#   This class describes a music instrumentalist entity, built from an
#   'instrumentalist' XML element from the UMS music namespace.
#
###############################################################################

class UmsMceInstrumentalist : UmsBaePerson
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
    UmsMceInstrumentalist(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "instrumentalist")

        # Mandatory 'instruments' element (collection of 'instrument' elements)
        $this.BuildInstruments(
            $this.GetOneXmlElement(
                $XmlElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "instruments"))
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