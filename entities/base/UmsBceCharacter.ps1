###############################################################################
#   Concrete entity class UmsBceCharacter
#==============================================================================
#
#   This class describes a character entity, built from a 'character' 
#   XML element from the UMS base namespace. This entity describes a character
#   in a fictional work.
#
###############################################################################

class UmsBceCharacter : UmsBaePerson
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
    UmsBceCharacter([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "character")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

}