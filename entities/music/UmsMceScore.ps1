###############################################################################
#   Concrete entity class UmsMceScore
#==============================================================================
#
#   This class describes a music score entity, built from a 'score' XML element
#   from the UMS music namespace. A music book is the published score of a
#   musical work.
#
###############################################################################

class UmsMceScore : UmsBaePublication
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # One or several characters which will be inserted between each name
    # in a list of catalog ids.
    static [string] $CatalogIdDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicCatalogIdListDelimiter").Value)
    
    # One or several characters which will be inserted before a list of
    # catalog ids.
    static [string] $CatalogIdListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicCatalogIdListPrefix").Value)

    # One or several characters which will be inserted after a list of
    # catalog ids.
    static [string] $CatalogIdListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicCatalogIdListSuffix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [UmsMceCatalogId[]]     $CatalogIds
    [UmsMceComposer[]]      $Composers

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMceScore([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "score")

        # Optional 'catalogIds' element
        if ($XmlElement.catalogIds)
        {
            $this.BuildCatalogIds(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "catalogIds"))
        }
        
        # Optional 'composers' element (collection of 'composer' elements)
        if ($XmlElement.composers)
        {
            $this.BuildComposers(
                $this.GetOneXmlElement(
                    $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "composers"))
        }
    }

    # Sub-constructor for the 'catalogIds' element
    [void] BuildCatalogIds([System.Xml.XmlElement] $CatalogIdsElement)
    {
        $this.GetOneOrManyXmlElement(
            $CatalogIdsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "catalogId"
        ) | foreach {
                $this.CatalogIds += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }    
    
    # Sub-constructor for the 'composers' element
    [void] BuildComposers([System.Xml.XmlElement] $ComposersElement)
    {
        $this.GetOneOrManyXmlElement(
            $ComposersElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "composer"
        ) | foreach {
                $this.Composers += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    [string] ToString()
    {
        $_string = ""
        $_addSpace = $false
        
        # Show composer list
        # Add space, if needed
        if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

        # Get an array of composer short names
        $_composers = @()
        foreach ($_composer in $this.Composers)
            { $_composers += $_composer.Name.ShortName }

        # Add composers to the buffer
        $_string += ([UmsMceScore]::ComposerListPrefix)
        $_string += ($_composers -join(
            [UmsMceScore]::ComposerDelimiter))
        $_string += ([UmsMceScore]::ComposerListSuffix)
        $_addSpace = $true

        # Include publication title. We use the ToString() method from the
        # UmsBaeProduct base type to get the string.
        # Add space, if needed
        if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

        # Add publication title to the buffer
        $_string += ([UmsBaeProduct] $this).ToString()
        $_addSpace = $true

        # Show catalog ids
        if ($this.CatalogIds)
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get an array of catalog ids
            $_catalogIds = @()
            foreach ($_catalogId in $this.CatalogIds)
                { $_catalogIds += $_catalogId.ToString() }

            # Add catalog ids to the buffer
            $_string += ([UmsMceScore]::CatalogIdListPrefix)
            $_string += ($_catalogIds -join(
                [UmsMceScore]::CatalogIdDelimiter))
            $_string += ([UmsMceScore]::CatalogIdListSuffix)
            $_addSpace = $true
        }

        return $_string
    }
}