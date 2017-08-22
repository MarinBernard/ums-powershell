###############################################################################
#   Concrete entity class UmsMceKey
#==============================================================================
#
#   This class describes a musical key entity, built from a 'key' XML element
#   from the music namespace.
#
###############################################################################

class UmsMceKey : UmsBaeItem
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether the first letter of a musical key must be capitalized.
    static [string] $CapitalizeFirstLetter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyCapitalizeFirstLetter").Value)

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
    UmsMceKey([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "key")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    [string] ToString()
    {
        $_string = ""
        $_originalString = ([UmsBaeItem] $this).ToString()

        if ([UmsMceKey]::CapitalizeFirstLetter)
        {
            $_string = $(
                $_originalString.Substring(0,1).ToUpper() + `
                $_originalString.Substring(1))
        }
        else
        {
            $_string = $_originalString
        }

        return $_string
    }

}