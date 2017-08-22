###############################################################################
#   Abstract entity class UmsAEEntity
#==============================================================================
#
#   This class represents an abstract UMS entity. It is an ancestor class for
#   all entity classes.
#
#   It must *NOT* be instantiated but rather be inherited by concrete entity
#   classes.
#
###############################################################################

class UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Catalog of namespace URIs for all instances.
    static [hashtable] $NamespaceUri = @{
        "Base"  = [ConfigurationStore]::GetSchemaItem("Base").Namespace;
        "Audio" = [ConfigurationStore]::GetSchemaItem("Audio").Namespace;
        "Music" = [ConfigurationStore]::GetSchemaItem("Music").Namespace;
    }

    # The non-breaking space character constant
    static [string] $NonBreakingSpace = $([char] 0x00A0)

    # The 2-letter ISO code of the prefered language
    static [string] $PreferredLanguage = (Get-Culture).TwoLetterISOLanguageName

    # The 2-letter ISO code of the fallback language
    static [string] $FallbackLanguage = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsFallbackLanguage").Value)

    # Whether default variants should be used before switching to fallback
    static [bool] $UseDefaultVariants = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsUseDefault").Value)

    # Whether original variants should be used as a last resort
    static [bool] $UseOriginalVariants = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsUseOriginal").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # XML-related properties
    hidden [string] $XmlNamespaceUri    # URI of the XML namespace
    hidden [string] $XmlElementName     # Unprefixed name of XML doc. element

    # Entity metadata
    hidden [string] $SourceFileUri  # URI to source transcluded file, if any
    hidden [string] $SourcePathUri  # URI to path of the trans. file, if any
    hidden [string] $Uid            # Uid of the entity, if set
    
    ###########################################################################
    # Visible properties
    ###########################################################################

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsAeEntity([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeVariant")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }
        
        # XML-related properties
        $this.XmlNamespaceUri = $XmlElement.NamespaceURI
        $this.XmlElementName  = $XmlElement.LocalName

        # Absolute URI to the source UMS file from which this entity was
        # instantiated.
        $this.SourceFileUri = $Uri.AbsoluteUri

        # Source path URI is built by truncating the absolute URI string
        # at length - length of the last segment.
        $this.SourcePathUri = [System.Uri]::New($Uri.AbsoluteUri.Substring(0, $Uri.AbsoluteUri.Length - $Uri.Segments[-1].Length)).AbsoluteUri

        # The "uid" attribute is optional and only specified with references
        if ($XmlElement.HasAttribute("uid"))
        {
            $this.Uid = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "uid")
        }
        if ($XmlElement.HasAttribute("src"))
        {
            $this.SourceFileUri = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "src")
        }
    }

    ###########################################################################
    # XML helpers
    ###########################################################################

    # Validates the namespace and local name of the suplied XML element. This
    # method is invoked by child constructors to validate a source XML element.
    [void] ValidateXmlElement(
        [System.Xml.XmlElement] $XmlElement,
        [string] $RequiredNamespaceUri, [string] $RequiredElementName)
    {
        if (($XmlElement.NamespaceURI -ne $RequiredNamespaceUri) -or
            ($XmlElement.LocalName -ne $RequiredElementName))
        {
            throw [UEIncompatibleXmlElementException]::New(
                $XmlElement.NamespaceURI,
                $RequiredNamespaceUri,
                $XmlElement.LocalName,
                $RequiredElementName,
                $this.getType().Name
            )
        }
    }

    # Returns an XML element if it is present exactly once. Raises an exception
    # otherwise.
    [System.Xml.XmlElement] GetOneXmlElement(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        $_elements = $XmlElement.ChildNodes.Where({
            ($_.NamespaceUri -eq $NamespaceUri) -and
            ($_.LocalName -eq $ElementName)
        })

        if ($_elements.Count -eq 1)
            { return $_elements[0] }
        else
        {
            throw [UEIllegalXmlElementCountException]::New(
                $NamespaceUri, $ElementName, $XmlElement.LocalName,
                $XmlElement.NamespaceUri, $_elements.Count, 1, 1)
        }
    }

    # Returns the value of an XML element if it is present exactly once.
    # Raises an exception otherwise.
    [string] GetOneXmlElementValue(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        return $this.GetOneXmlElement(
            $XmlElement, $NamespaceUri, $ElementName).'#text'
    }

    # Returns all occurrences of an XML element if it is present at least once.
    #  Raises an exception in any other case.
    [System.Xml.XmlElement[]] GetOneOrManyXmlElement(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        $_elements = $XmlElement.ChildNodes.Where({
            ($_.NamespaceUri -eq $NamespaceUri) -and
            ($_.LocalName -eq $ElementName)
        })

        if ($_elements.Count -ge 1)
            { return $_elements }
        else
        {
            throw [UEIllegalXmlElementCountException]::New(
                $NamespaceUri, $ElementName, $XmlElement.NamespaceUri,
                $XmlElement.LocalName, $_elements.Count, 1, -1)
        }
    }
    
    # Returns all occurrences of an XML element no matter how many of them are
    # present. Returns an empty XmlElement if the XML element does not exist.
    [System.Xml.XmlElement[]] GetZeroOrManyXmlElement(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        return $XmlElement.ChildNodes.Where({
            ($_.NamespaceUri -eq $NamespaceUri) -and
            ($_.LocalName -eq $ElementName)
        })
    }  

    # Returns an XML element if it is present exactly once. Returns an empty
    # XmlElement if the element does not exist. Raises an exception in any
    # other case.
    [System.Xml.XmlElement] GetZeroOrOneXmlElement(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        $_elements = $XmlElement.ChildNodes.Where({
            ($_.NamespaceUri -eq $NamespaceUri) -and
            ($_.LocalName -eq $ElementName)
        })
        
        if ($_elements.Count -le 1)
            { return $_elements[0] }
        else
        {
            throw [UEIllegalXmlElementCountException]::New(
                $NamespaceUri, $ElementName, $XmlElement.NamespaceUri,
                $XmlElement.LocalName, $_elements.Count, 0, 1)
        }
    }

    # Returns the value of an XML element if it is present exactly once.
    # Returns an empty string if the element is absent. Raises an exception
    # in any other case.
    [string] GetZeroOrOneXmlElementValue(
        [System.Xml.XmlElement] $XmlElement,
        [string] $NamespaceUri,
        [string] $ElementName)
    {
        return $this.GetZeroOrOneXmlElement(
            $XmlElement, $NamespaceUri, $ElementName).'#text'
    }

    # Returns the value of an XML attribute if it is present, or an exception
    # if it is missing.
    [string] GetMandatoryXmlAttributeValue(
        [System.Xml.XmlElement] $XmlElement, [string] $Name)
    {
        if ($XmlElement.HasAttribute($Name))
            { return $XmlElement.GetAttribute($Name) }
        else
        {
            throw [UEMissingXmlElementAttributeException]::New(
                $Name,
                $XmlElement.NamespaceUri,
                $XmlElement.LocalName)
        }
    }

    # Returns the value of an XML attribute if it is present, of an empty
    # XmlElement if it is not.
    [string] GetOptionalXmlAttributeValue(
        [System.Xml.XmlElement] $XmlElement, [string] $Name)
    {
        return $XmlElement.GetAttribute($Name)
    }
}