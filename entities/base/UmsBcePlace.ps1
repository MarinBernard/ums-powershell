###############################################################################
#   Concrete entity class UmsBcePlace
#==============================================================================
#
#   This class describes a standard place, built from an XML 'place' element
#   element from the base namespace. The 'place' concrete entity inherits from
#   the 'place' abstract entity and adds nothing to its base type.
#
###############################################################################

class UmsBcePlace : UmsBaePlace
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
    UmsBcePlace([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "place")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}