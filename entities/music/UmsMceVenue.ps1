###############################################################################
#   Concrete entity class UmsMceVenue
#==============================================================================
#
#   This class describes a musical venue place entity, built from a 'venue'
#   XML element from the music namespace.
#
###############################################################################

class UmsMceVenue : UmsBaePlace
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
    UmsMceVenue([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "venue")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}