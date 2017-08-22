###############################################################################
#   Concrete entity class UmsBceSymbolVariant
#==============================================================================
#
#   This class describes a symbol variant entity, built from an XML
#   'symbolVariant' element from the UMS base namespace.
#
###############################################################################

class UmsBceSymbolVariant : UmsBaeVariant
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

    [string] $Symbol

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceSymbolVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "symbolVariant")
        
        # Symbol value
        $this.Symbol =  $XmlElement.'#text'       

        # Build variant flags thanks to the parent class
        $this.Flags = $this.BuildVariantFlags()
    }

    ###########################################################################
    # Helpers
    ###########################################################################
    
    # String representation
    [string] ToString()
    {
        return $this.Symbol
    }
}