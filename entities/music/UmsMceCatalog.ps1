###############################################################################
#   Concrete entity class UmsMceCatalog
#==============================================================================
#
#   This class describes a music catalog entity, built from an 'catalog'
#   XML element from the music namespace. It extends the base abstract type
#   defining common members for standard-related entities.
#
###############################################################################

class UmsMceCatalog : UmsBaeStandard
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
    UmsMceCatalog([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "catalog")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}