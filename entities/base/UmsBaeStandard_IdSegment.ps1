###############################################################################
#   Local class UmsBaeStandard_IdSegment
#==============================================================================
#
#   Describes a standard segment. It is used as an internal resource by the
#   UmsBaeStandard and UmsBaeStandardId entity classes.
#
###############################################################################

class UmsBaeStandard_IdSegment
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

    [int]       $Level
    [string]    $Value

    ###########################################################################
    # Constructors
    ###########################################################################

    UmsBaeStandard_IdSegment([System.Xml.XmlElement] $XmlElement)
    {
        # Mandatory 'level' attribute
        if ($XmlElement.HasAttribute("level"))
            { $this.Level = $XmlElement.GetAttribute("level") }
        else
        {
            throw [UEMissingXmlElementAttributeException]::New(
                "level", $XmlElement.NamespaceURI, $XmlElement.LocalName)
        }

        # Get segment value
        $this.Value = $XmlElement.'#text'
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    [string] ToString()
    {
        return $this.Value
    }
}