###############################################################################
#   Abstract entity class UmsBaseAbstractResourceEntity
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic
#   resource. The specificity of a resource entity is to represent a single,
#   self-sufficient piece of information. For instance, language variant
#   entities are not resources, as they are not self-sufficient.
#
#   This abstract type has not equivalent in the XML schema. Its goal is to
#   lighten class definitions by regrouping pieces of code which are common
#   to all resources, such as the management of link variants and standard ids.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaseAbstractResourceEntity : UmsAbstractEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Collection of all link variants
    hidden [UmsBceLinkVariant[]] $LinkVariants

    # Collection of standard Ids
    # The type of the items in the collection is always UmsBceStandardId, but
    # could not be specified as-is due to a dependency loop.
    # Tags:
    # - DependencyLoopPrevention
    [UmsAbstractEntity[]] $StandardIds

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Elected link variants
    [UmsBceLinkVariant[]] $Links

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaseAbstractResourceEntity([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaseAbstractResourceEntity")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Build optional link variants
        $this.BuildLinkVariants(
            $this.GetZeroOrOneXmlElement(
                $XmlElement, [UmsAbstractEntity]::NamespaceUri.Base, "linkVariants"))

        # Build optional standard ids
        $this.BuildStandardIds(
            $this.GetZeroOrOneXmlElement(
                $XmlElement, [UmsAbstractEntity]::NamespaceUri.Base, "standardIds"))
    }

    # Builds instances of all link variants and elects those which fit
    # the best language.
    [void] BuildLinkVariants([System.Xml.XmlElement] $LinkVariantsElement)
    {
        $this.GetZeroOrManyXmlElement(
            $LinkVariantsElement,
            [UmsAbstractEntity]::NamespaceUri.Base,
            "linkVariant"
        ) | foreach {
                $this.LinkVariants += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }

        # Select the best link variant for each resource type
        $_groups = $this.LinkVariants | Group-Object -Property ResourceType
        foreach ($_group in $_groups)
        {
            $this.Links += [UmsBaeVariant]::GetBestVariant($_group.Group)
        }
    }

    # Builds instances of all standard ids.
    [void] BuildStandardIds([System.Xml.XmlElement] $StandardIdsElement)
    {
        $this.GetZeroOrManyXmlElement(
            $StandardIdsElement,
            [UmsAbstractEntity]::NamespaceUri.Base,
            "standardId"
        ) | foreach {
                $this.StandardIds += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ########################################################################### 
}