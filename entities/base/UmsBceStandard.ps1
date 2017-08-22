###############################################################################
#   Concrete entity class UmsBceStandard
#==============================================================================
#
#   This class describes a standard entity, built from an XML 'standard'
#   element from the base namespace.
#
###############################################################################

class UmsBceStandard : UmsBaeStandard
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

    # Parent standard. Not implemented in UmsBaeStandard, as it is very seldom
    # used.
    [UmsBceStandard] $Parent

    # Superset standards, which supersede the current standard.
    [UmsBceStandard] $Supersets

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceStandard([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "standard")

        # Optional 'parent' element (wrapper of a single 'standard' element)
        if ($XmlElement.parent)
        {
            $this.BuildParent(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "parent"))     
        }

        # Optional 'supersets' element (collection of a 'standard' elements)
        if ($XmlElement.supersets)
        {
            $this.BuildSupersets(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "supersets"))     
        }
    }

    # Sub-constructor for the 'parent/standard' element
    [void] BuildParent([System.Xml.XmlElement] $ParentElement)
    {
        $this.Parent = (
            [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $ParentElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "standard"),
                $this.SourcePathUri,
                $this.SourceFileUri))
    }

    # Sub-constructor for the 'supersets' element
    [void] BuildSupersets([System.Xml.XmlElement] $SupersetsElement)
    {
        $this.GetOneOrManyXmlElement(
            $SupersetsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "standard"
        ) | foreach {
            $this.Supersets += [EntityFactory]::GetEntity(
                $_, $this.SourcePathUri, $this.SourceFileUri) }
    }  

    ###########################################################################
    # Helpers
    ###########################################################################
}