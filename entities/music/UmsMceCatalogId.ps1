###############################################################################
#   Concrete entity class UmsMceCatalogId
#==============================================================================
#
#   This class describes a music catalog if entity, built from a 'catalogId'
#   XML element from the UMS music namespace. This class extends the base
#   abstract type UmsBaeStandardId, which defines common members for all
#   entities which aim to link a Standard to a Standard Record.
#
###############################################################################

class UmsMceCatalogId : UmsBaeStandardId
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

    # Music catalog
    [UmsMceCatalog] $Catalog

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMceCatalogId([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "catalogId")

        # Mandatory 'catalog' element
        $this.Catalog = (
            [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "catalog"),
                $this.SourcePathUri,
                $this.SourceFileUri))

        # Register the catalog as the standard
        $this.RegisterStandard($this.Catalog)
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # String representation. Music catalogs do not use any separator between
    # the catalog name and the catalog number, so we must override the
    # ToString() method of the parent class.
    [string] ToString()
    {
        $_string = ""

        $_string += $this.Catalog.Label.ShortLabel
        $_string += [UmsAeEntity]::NonBreakingSpace
        $_string += $this.Id
       
        return $_string
    }
}