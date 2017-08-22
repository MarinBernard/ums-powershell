###############################################################################
#   Concrete entity class UmsBceInception
#==============================================================================
#
#   This class describes a composition inception event entity, built from an
#   'inception' XML element from the base namespace. This describes the date
#   and place of inception of something.
#
###############################################################################

class UmsBceInception : UmsBaeEvent
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
    UmsBceInception([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "inception")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

}