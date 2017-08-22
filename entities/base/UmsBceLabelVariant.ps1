###############################################################################
#   Concrete entity class UmsBceLabelVariant
#==============================================================================
#
#   This class describes a label variant entity, built from an XML
#   'labelVariant' element from the UMS base namespace.
#
###############################################################################

class UmsBceLabelVariant : UmsBaeVariant
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether common labels should be prefered when present
    static [bool] $PreferCommonLabels = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsPreferCommonLabels").Value)

    # Whether a fake sort-friendly label should be created from the full form
    # when no sort label was defined.
    static [bool] $UseFakeSortVariants = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsUseFakeSortVariants").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Imported raw
    hidden [string] $FullLabelRaw
    hidden [string] $SortLabelRaw
    hidden [string] $CommonLabel

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Calculated
    [string] $FullLabel
    [string] $SortLabel

    # As-is
    [string] $ShortLabel    

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceLabelVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "labelVariant")
        
        # Child elements
        $this.FullLabelRaw =  $this.GetOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "fullLabel")
        $this.SortLabelRaw = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "sortLabel")
        $this.CommonLabel  =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "commonLabel")
        $this.ShortLabel =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "shortLabel")            

        # Build variant flags thanks to the parent class
        $this.Flags = $this.BuildVariantFlags()

        # Calculated values are set by helpers
        $this.FullLabel = $this.BuildFullLabel()
        $this.SortLabel = $this.BuildSortLabel()
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Builds and returns the full label of an item.
    [string] BuildFullLabel()
    {
        # We common labels are prefered and a common label is set, use it.
        if (
            ([UmsBceLabelVariant]::PreferCommonLabels) -and ($this.CommonLabel))
            { return $this.CommonLabel }
        
        # Else, let's use the regular full label
        return $this.FullLabelRaw
    }

    # Builds and returns the sort-friendly label of an item.
    [string] BuildSortLabel()
    {
        # If a sort label is available, we use it
        if ($this.SortLabelRaw)
            { return $this.SortLabelRaw }
        
        # If not and fake sort variants are enabled, let's use the full form.
        elseif ([UmsBceLabelVariant]::UseFakeSortVariants)
            { return $this.FullLabel }

        # Else, we return an empty string.
        else
            { return "" }
    }
    
    # String representation
    [string] ToString()
    {
        return $this.FullLabel
    }
}