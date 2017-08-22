###############################################################################
#   Concrete entity class UmsBceTitleVariant
#==============================================================================
#
#   This class describes a title variant entity, built from an XML
#   'titleVariant' element from the UMS base namespace.
#
###############################################################################

class UmsBceTitleVariant : UmsBaeVariant
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether a fake sort-friendly title should be created from the full form
    # when no sort title was defined.
    static [bool] $UseFakeSortVariants = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsUseFakeSortVariants").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Imported raw
    hidden [string] $SortTitleRaw

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Imported raw
    [string] $FullTitle

    # Calculated
    [string] $SortTitle

    # Imported raw
    [string] $Subtitle

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceTitleVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "titleVariant")
        
        # Child elements
        $this.FullTitle =  $this.GetOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "fullTitle")
        $this.SortTitleRaw = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "sortTitle")
        $this.Subtitle  =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "subtitle")         

        # Buld variant flags thanks to the parent class
        $this.Flags = $this.BuildVariantFlags()

        # Calculated values are set by helpers
        $this.SortTitle = $this.BuildSortTitle()
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Builds and returns the sort-friendly title of an item.
    [string] BuildSortTitle()
    {
        # If a sort title is available, we use it
        if ($this.SortTitleRaw)
            { return $this.SortTitleRaw }
        
        # If not and fake sort variants are enabled, let's use the full form.
        elseif ([UmsBceTitleVariant]::UseFakeSortVariants)
            { return $this.FullTitle }

        # Else, we return an empty string.
        else
            { return ""}
    }
    
    # String representation
    [string] ToString()
    {
        return $this.FullTitle
    }
}