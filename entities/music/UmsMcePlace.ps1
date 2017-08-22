###############################################################################
#   Concrete entity class UmsMcePlace
#==============================================================================
#
#   This class describes a musical place, built from an XML 'place' element
#   element from the music namespace. The 'place' concrete entity inherits from
#   the 'place' abstract entity and adds nothing to its base type.
#   Musical places are identical to base places except that they allow
#   references to musical venues.
#
###############################################################################

class UmsMcePlace : UmsMaePlace
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

    # Standard constructor.
    UmsMcePlace([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "place")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}