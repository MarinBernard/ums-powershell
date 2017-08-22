###############################################################################
#   Concrete entity class UmsMceWork
#==============================================================================
#
#   This class describes a music work entity, built from a 'work' XML element
#   from the UMS music namespace.
#
###############################################################################

class UmsMceWork : UmsBaeProduct
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether a list of composers of the work should be shown when it is
    # rendered as a string.
    static [bool] $ShowComposerList = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkComposerListShow").Value)

    # One or several characters which will be inserted between each name
    # in a list of composers.
    static [string] $ComposerDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkComposerListDelimiter").Value)
    
    # One or several characters which will be inserted before a list of
    # composers.
    static [string] $ComposerListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkComposerListPrefix").Value)

    # One or several characters which will be inserted after a list of
    # composers.
    static [string] $ComposerListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkComposerListSuffix").Value)

    # Whether the main musical key of the work should be shown when it is
    # rendered as a string.
    static [bool] $ShowMusicalKey = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkMusicalKeyShow").Value)

    # Whether musical keys will be displayed as their short form.
    static [bool] $PreferShortKeys = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyPreferShort").Value)
    
    # One or several characters which will be inserted before a list of keys.
    static [string] $MusicalKeyPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyPrefix").Value)

    # One or several characters which will be inserted after a list of keys.
    static [string] $MusicalKeySuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeySuffix").Value)
    
    # Whether the catalog IDs of the work should be shown when it is
    # rendered as a string.
    static [bool] $ShowCatalogIds = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkCatalogIdListShow").Value)

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

    # Whether the year of completion of the work will be shown when it is
    # rendered as a string.
    static [bool] $ShowWorkCompletionYear = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListCompletionShow").Value)

    # Whether the year of inception of the work will be shown when it is
    # rendered as a string.
    static [bool] $ShowWorkInceptionYear = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListInceptionShow").Value)

    # Whether the year of the premiere of the work will be shown when it is
    # rendered as a string.
    static [bool] $ShowWorkPremiereYear = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListPremiereShow").Value)

    # One or several characters which will be inserted between each year
    # in a list of years, when the work is rendered as a string.
    static [string] $YearListDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListDelimiter").Value)

    # One or several characters which will be inserted before the year of
    # inception/completion/premiere, when the work is rendered as a string.
    static [string] $YearListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListPrefix").Value)

    # One or several characters which will be inserted after the year of
    # inception/completion/premiere, when the work is rendered as a string.
    static [string] $YearListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalWorkYearListSuffix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [UmsMceCatalogId[]]     $CatalogIds
    [UmsMceComposer[]]      $Composers
    [UmsMceInstrument[]]    $Instruments
    [UmsMceKey]             $Key
    [UmsBceCharacter[]]     $Characters
    [UmsMceForm]            $Form
    [UmsMceStyle]           $Style
    [UmsMceScore]           $Score
    [UmsBceInception]       $Inception
    [UmsBceCompletion]      $Completion
    [UmsMcePremiere]        $Premiere
    [UmsMceSection[]]       $Sections

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMceWork([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "work")

        # Optional 'catalogIds' element
        if ($XmlElement.catalogIds)
        {
            $this.BuildCatalogIds(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "catalogIds"))
        }

        # Optional 'inception' element
        if ($XmlElement.inception)
        {
            $this.Inception = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "inception"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # Optional 'completion' element
        if ($XmlElement.completion)
        {
            $this.Completion = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "completion"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # Optional 'premiere' element
        if ($XmlElement.premiere)
        {
            $this.Premiere = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "premiere"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # Mandatory 'key' element
        $this.Key = (
            [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "key"),
                $this.SourcePathUri,
                $this.SourceFileUri))

        # Optional 'characters' element (collection of 'character' elements)
        if ($XmlElement.characters)
        {
            $this.BuildCharacters(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "characters"))     
        }

        # Optional 'score' element
        if ($XmlElement.score)
        {
            $this.Score = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "score"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }
        
        # Mandatory 'composers' element (collection of 'composer' elements)
        $this.BuildComposers(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "composers"))

        # Mandatory 'instruments' element (collection of 'instrument' elements)
        $this.BuildInstruments(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "instruments"))

        # Mandatory 'form' element
        $this.Form = [EntityFactory]::GetEntity(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "form"),
            $this.SourcePathUri,
            $this.SourceFileUri)

        # Mandatory 'style' element
        $this.Style = [EntityFactory]::GetEntity(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "style"),
            $this.SourcePathUri,
            $this.SourceFileUri)
        
        # Mandatory 'sections' element (collection of 'section' elements)
        $this.BuildSections(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "sections"))
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
    
    # Sub-constructor for the 'instruments' element
    [void] BuildInstruments([System.Xml.XmlElement] $InstrumentsElement)
    {
        $this.GetOneOrManyXmlElement(
            $InstrumentsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "instrument"
        ) | foreach {
                $this.Instruments += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    # Sub-constructor for the 'characters' element
    [void] BuildCharacters([System.Xml.XmlElement] $CharactersElement)
    {
        $this.GetOneOrManyXmlElement(
            $CharactersElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "character"
        ) | foreach {
                $this.Characters += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    # Sub-constructor for the 'sections' element
    [void] BuildSections([System.Xml.XmlElement] $SectionsElement)
    {
        $this.GetOneOrManyXmlElement(
            $SectionsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "section"
        ) | foreach {
                $this.Sections += [EntityFactory]::GetEntity(
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
        if ([UmsMceWork]::ShowComposerList)
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get an array of composer short names
            $_composers = @()
            foreach ($_composer in $this.Composers)
                { $_composers += $_composer.Name.ShortName }

            # Add composers to the buffer
            $_string += ([UmsMceWork]::ComposerListPrefix)
            $_string += ($_composers -join(
                [UmsMceWork]::ComposerDelimiter))
            $_string += ([UmsMceWork]::ComposerListSuffix)
            $_addSpace = $true
        }

        # Include work title. We use the ToString() method from the
        # UmsBaeProduct base type to get the string.
        # Add space, if needed
        if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

        # Add work title to the buffer
        $_string += ([UmsBaeProduct] $this).ToString()
        $_addSpace = $true

        # Show musical key
        if (([UmsMceWork]::ShowMusicalKey) -and ($this.Key))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get key value
            if ([UmsMceWork]::PreferShortKeys)
                { $_key = $this.Key.Label.ShortLabel }
            else
                { $_key = $this.Key.Label.FullLabel }

            # Add musical key to the buffer
            $_string += ([UmsMceWork]::MusicalKeyPrefix)
            $_string += $_key
            $_string += ([UmsMceWork]::MusicalKeySuffix)
            $_addSpace = $true
        }

        # Show catalog ids
        if (([UmsMceWork]::ShowCatalogIds) -and ($this.CatalogIds))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get an array of catalog ids
            $_catalogIds = @()
            foreach ($_catalogId in $this.CatalogIds)
                { $_catalogIds += $_catalogId.ToString() }

            # Add catalog ids to the buffer
            $_string += ([UmsMceWork]::CatalogIdListPrefix)
            $_string += ($_catalogIds -join(
                [UmsMceWork]::CatalogIdDelimiter))
            $_string += ([UmsMceWork]::CatalogIdListSuffix)
            $_addSpace = $true
        }

        # Build the list of years
        [string[]] $_years = @()
        # Inception year
        if (([UmsMceWork]::ShowWorkInceptionYear) -and ($this.Inception))
        {
            $_years += (Get-Date -Date $this.Inception.Date -Format "yyyy")
        }
        # Completion year
        if (([UmsMceWork]::ShowWorkCompletionYear) -and ($this.Completion))
        {
            $_years += (Get-Date -Date $this.Completion.Date -Format "yyyy")
        }
        # Premiere year
        if (([UmsMceWork]::ShowWorkPremiereYear) -and ($this.Premiere))
        {
            $_years += (Get-Date -Date $this.Premiere.Date -Format "yyyy")
        }

        # Render the list of years
        if ($_years.Count -gt 0)
        {
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }
            $_string += ([UmsMceWork]::YearListPrefix)
            $_string += ($_years -join([UmsMceWork]::YearListDelimiter))
            $_string += ([UmsMceWork]::YearListSuffix)
        }

        return $_string
    }

}