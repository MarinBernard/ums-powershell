###############################################################################
#   Concrete entity class UmsBceStandardId
#==============================================================================
#
#   This class describes a standard id entity, built from an XML 'standardId'
#   element from the base namespace.
#
###############################################################################

class UmsBceStandardId : UmsBaeStandardId
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
    UmsBceStandardId([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "standardId")

        # Mandatory 'standard' element
        $_standard = (
            [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "standard"),
                $this.SourcePathUri,
                $this.SourceFileUri))
        
        # Register the standard
        $this.RegisterStandard($_standard)  
    }

    ###########################################################################
    # Helpers
    ###########################################################################
    
    # String representation
    [string] ToString()
    {
        return $($this.Standard.ToString() + ": " + $this.Id)
    }
}