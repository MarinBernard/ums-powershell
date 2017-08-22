###############################################################################
#   Abstract entity class UmsBaseAbstractProductEntity
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

class UmsBaseAbstractProductEntity : UmsBaseAbstractResourceEntity
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
    UmsBaseAbstractProductEntity([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaseAbstractProductEntity")
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
                    [UmsAbstractEntity]::NamespaceUri.Base,
                    "titleVariants"))
        }
    }

    # Builds instances of all title variants and elects the best one.
    [void] BuildTitleVariants([System.Xml.XmlElement] $TitleVariantsElement)
    {
        $this.GetOneOrManyXmlElement(
            $TitleVariantsElement,
            [UmsAbstractEntity]::NamespaceUri.Base,
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