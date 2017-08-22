###############################################################################
#   Concrete entity class UmsBceLinkVariant
#==============================================================================
#
#   This class describes a link variant entity, built from an XML
#   'linkVariant' element from the base namespace.
#
###############################################################################

class UmsBceLinkVariant : UmsBaeVariant
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

    # Imported raw
    [string] $ResourceType
    [string] $Url

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceLinkVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "linkVariant")

        # Attributes
        $this.ResourceType = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "type")
        $this.Language = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "lang")
        $this.IsDefault = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "default")
        $this.IsOriginal = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "original")
        $this.Url = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "href")
        
        # This item has no child elements

        # Build variant flags thanks to the parent class
        $this.Flags = $this.BuildVariantFlags()
    }

    ###########################################################################
    # Helpers
    ###########################################################################
    
    # String representation
    [string] ToString()
    {
        return $this.ResourceType
    }
}