###############################################################################
#   Concrete entity class UmsBcePictureVariant
#==============================================================================
#
#   This class describes a picture variant entity, built from an XML
#   'pictureVariant' element from the base namespace.
#
###############################################################################

class UmsBcePictureVariant : UmsBaeVariant
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Raw src attribute
    hidden [string] $Src

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Imported raw
    [string] $PictureType

    # Calculated
    [System.Uri] $Uri

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBcePictureVariant(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $Uri)
    : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "pictureVariant")

        # Attributes
        $this.PictureType = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "type")
        $this.Language = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "lang")
        $this.IsDefault = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "default")
        $this.IsOriginal = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "original")
        $this.Src = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "src")

        # Update the Uri property
        if ($this.Src -like "*://*")
        {
            $this.Uri = [System.Uri]::New($this.Src)
        }
        else
        {
            $_absUri = [System.Uri]::New($this.SourcePathUri)
            $_relUri = [System.Uri]::New($this.Src, [System.UriKind]::Relative)
            $this.Uri = [System.Uri]::New($_absUri, $_relUri)
        }
        
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
        return $this.PictureType
    }
}