###############################################################################
#   Concrete entity class UmsMcePremiere
#==============================================================================
#
#   This class describes a composition premiere event entity, built from an
#   'premiere' XML element from the music namespace. This describes the date
#   and place at which the premiere of a music work took place.
#   This entity inherits the UmsMaeEvent class rather that the UmsBaeEvent
#   class. This means it supports specifying a musical venue as an event place.
#
###############################################################################

class UmsMcePremiere : UmsMaeEvent
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
    UmsMcePremiere([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "premiere")
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}