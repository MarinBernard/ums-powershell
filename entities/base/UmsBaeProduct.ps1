###############################################################################
#   Abstract entity class UmsBaeProduct
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic product.
#   It deals with properties defined in the 'Product' abstract type from the
#   XML schema.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeProduct : UmsBaeResource
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Collection of all title variants
    hidden [UmsBceTitleVariant[]] $TitleVariants

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Elected title variant
    [UmsBceTitleVariant] $Title

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeProduct([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeProduct")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Build optional title variants
        if ($XmlElement.titleVariants)
        {
            $this.BuildTitleVariants(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "titleVariants"))
        }
    }

    # Builds instances of all title variants and elects the best one.
    [void] BuildTitleVariants([System.Xml.XmlElement] $TitleVariantsElement)
    {
        $this.GetOneOrManyXmlElement(
            $TitleVariantsElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "titleVariant"
        ) | foreach {
                $this.TitleVariants += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }

        # Get the best label variant
        $this.Title = [UmsBaeVariant]::GetBestVariant($this.TitleVariants)
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # String representation
    [string] ToString()
    {
        return $this.Title
    }

}