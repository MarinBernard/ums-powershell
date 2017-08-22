###############################################################################
#   Abstract entity class UmsBaeItem
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic item.
#   It deals with properties defined in the 'Item' abstract type from the XML
#   schema.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeItem : UmsBaeResource
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Collection of all label variants
    hidden [UmsBceLabelVariant[]] $LabelVariants

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Elected label variant
    [UmsBceLabelVariant] $Label

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeItem([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeItem")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Build optional label variants
        $this.BuildLabelVariants(
            $this.GetZeroOrOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "labelVariants"))
    }

    # Builds instances of all label variants and elects the best one.
    [void] BuildLabelVariants([System.Xml.XmlElement] $LabelVariantsElement)
    {
        $this.GetZeroOrManyXmlElement(
            $LabelVariantsElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "labelVariant"
        ) | foreach {
                $this.LabelVariants += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }

        # Get the best label variant
        $this.Label = [UmsBaeVariant]::GetBestVariant($this.LabelVariants)
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # String representation
    [string] ToString()
    {
        return $this.Label
    }

}