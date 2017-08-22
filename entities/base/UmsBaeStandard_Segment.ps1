###############################################################################
#   Local class UmsBaeStandard_Segment
#==============================================================================
#
#   Describes a standard segment. It is used as an internal resource by the
#   UmsBaeStandard class.
#
###############################################################################

class UmsBaeStandard_Segment
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # List of segment delimiters which must be included with a blank space
    # before and after the delimiter itself.
    [UmsBaeStandard_SegmentDelimiter[]] $SpacedDelimiters = @(
        [UmsBaeStandard_SegmentDelimiter]::Numero
    )

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [int]       $Order
    [bool]      $Mandatory
    [UmsBaeStandard_SegmentDelimiter]  $Delimiter

    ###########################################################################
    # Constructors
    ###########################################################################

    UmsBaeStandard_Segment([System.Xml.XmlElement] $XmlElement)
    {
        if ($XmlElement.HasAttribute("order"))
            { $this.Order = $XmlElement.GetAttribute("order") }
        else
        {
            throw [UEMissingXmlElementAttributeException]::New(
                "order", $XmlElement.NamespaceURI, $XmlElement.LocalName)
        }

        if ($XmlElement.HasAttribute("mandatory"))
            { $this.Mandatory = [System.Boolean]::Parse(
                $XmlElement.GetAttribute("mandatory")) }
        else
        {
            throw [UEMissingXmlElementAttributeException]::New(
                "mandatory", $XmlElement.NamespaceURI, $XmlElement.LocalName)
        }

        if ($XmlElement.HasAttribute("delimiter"))
            { $this.Delimiter = $XmlElement.GetAttribute("delimiter") }
        else
        {
            throw [UEMissingXmlElementAttributeException]::New(
                "delimiter", $XmlElement.NamespaceURI, $XmlElement.LocalName)
        }            
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    [string] GetPrefix()
    {
        [string] $_string = ""

        # Include optional space before the delimiter
        if ([UmsBaeStandard_Segment]::SpacedDelimiters -contains(
            $this.Delimiter))
        {
            $_string += ([UmsAeEntity]::NonBreakingSpace)
        }

        switch ($this.Delimiter)
        {
            "dash"      { $_string += "-" }
            "dot"       { $_string += "." }
            "numero"    { $_string += "n°" }
            "space"     { $_string += [UmsAeEntity]::NonBreakingSpace }
            "none"      {}
        }

        # Include optional space after the delimiter
        if ([UmsBaeStandard_Segment]::SpacedDelimiters -contains(
            $this.Delimiter))
        {
            $_string += ([UmsAeEntity]::NonBreakingSpace)
        }

        return $_string
    }
}

###############################################################################
#   Local enum UmsBaeStandard_SegmentDelimiter
#==============================================================================
#
#   Describes a delimiter prefix in a standard's segment.
#
###############################################################################

Enum UmsBaeStandard_SegmentDelimiter
{
    Dash
    Dot
    None
    Numero
    Space
}