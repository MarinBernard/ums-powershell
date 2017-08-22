###############################################################################
#   Concrete entity class UmsBceRelease
#==============================================================================
#
#   This class describes a release event entity, built from a 'release'
#   XML element from the base namespace. This entity describes a generic
#   release event. It is mainly used in children of the UmsBaePublication
#   asbtract type.
#
###############################################################################

class UmsBceRelease : UmsBaeEvent
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
    UmsBceRelease([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "release")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}