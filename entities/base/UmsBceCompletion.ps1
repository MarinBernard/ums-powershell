###############################################################################
#   Concrete entity class UmsBceCompletion
#==============================================================================
#
#   This class describes a composition completion event entity, built from an
#   'completion' XML element from the base namespace. This describes the date
#   and place at which something was completed.
#
###############################################################################

class UmsBceCompletion : UmsBaeEvent
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
    UmsBceCompletion([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "completion")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}