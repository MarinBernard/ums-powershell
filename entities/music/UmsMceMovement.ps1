###############################################################################
#   Concrete entity class UmsMceMovement
#==============================================================================
#
#   This class describes a music movement entity, built from a 'movement'
#   XML element from the UMS music namespace. Movement entities describe a
#   movement from a musical work. They are grouped together by UmsMceSection
#   entities.
#
###############################################################################

class UmsMceMovement : UmsBaeProduct
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether the musical form of the movement should be shown when it is
    # rendered as a string.
    static [bool] $ShowMusicalForm = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementFormListShow").Value)

    # One or several characters which will be inserted between each form name.
    static [string] $FormDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementFormListDelimiter").Value)
    
    # One or several characters which will be inserted before a form list.
    static [string] $FormListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementFormListPrefix").Value)

    # One or several characters which will be inserted after a form list.
    static [string] $FormListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementFormListSuffix").Value)

    # Whether the initial musical key of the movement should be shown when
    # it is rendered as a string.
    static [bool] $ShowMusicalKey = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementMusicalKeyShow").Value)

    # Whether musical keys will be displayed as their short form.
    static [bool] $PreferShortKeys = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyPreferShort").Value)
    
    # One or several characters which will be inserted before a list of keys.
    static [string] $KeyListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyPrefix").Value)

    # One or several characters which will be inserted after a list of keys.
    static [string] $KeyListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeySuffix").Value)

    # Whether the characters involved in the movement should be shown when
    # it is rendered as a string.
    static [bool] $ShowCharacterList = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementCharacterListShow").Value)

    # One or several characters which will be inserted between each name
    # in a list of characters.
    static [string] $CharacterDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementCharacterListDelimiter").Value)
    
    # One or several characters which will be inserted before a list of
    # characters.
    static [string] $CharacterListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementCharacterListPrefix").Value)

    # One or several characters which will be inserted after a list of
    # characters.
    static [string] $CharacterListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementCharacterListSuffix").Value)

    # Whether the title of the mouvement should be shown when it is rendered
    # as a string.
    static [bool] $ShowMovementTitle = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementTitleShow").Value)
    
    # One or several characters which will be inserted between the first and
    # second parts of the full movement title, when rendered as a string.
    static [string] $MovementTitleInfix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementTitleInfix").Value)

    # Whether tempo marking should be shown when the movement is rendered
    # as a string.
    static [bool] $ShowTempoMarking = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementTempoMarkingListShow").Value)
    
    # One or several characters which will be inserted before a list of
    # tempo markings.
    static [string] $TempoMarkingListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementTempoMarkingListPrefix").Value)
    
    # One or several characters which will be inserted after a list of
    # tempo markings.
    static [string] $TempoMarkingListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementTempoMarkingListSuffix").Value)

    # Whether the incipit of the movement should be shown when it is rendered
    # as a string.
    static [bool] $ShowMovementIncipit = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementIncipitShow").Value)
    
    # One or several characters which will be inserted before an incipit.
    static [string] $IncipitPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementIncipitPrefix").Value)
    
    # One or several characters which will be inserted after an incipit.
    static [string] $IncipitSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalMovementIncipitSuffix").Value)
    
    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Parent section of the movement. We cannot use the UmsMceSection type name
    # because there is a dependency loop between the UmsMceSection and
    # UmsMceMovement types. We cast the section to its nearer parent type to
    # avoid errors at compile time.
    # Tags:
    # - DependencyLoopPrevention
    hidden [UmsBaeProduct] $ParentSection

    ###########################################################################
    # Visible properties
    ###########################################################################

    [string]                $TimeSignature
    [string]                $TempoMarking
    [string]                $Incipit
    [UmsMceLyricist[]]      $Lyricists
    [UmsMceKey]             $Key
    [UmsBceCharacter[]]     $Characters
    [UmsMceInstrument[]]    $Instruments
    [UmsMceForm[]]          $Forms
    [UmsMceCatalogId[]]     $CatalogIds

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMceMovement([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "movement")

        # Mandatory 'timeSignature' element
        $this.TimeSignature = (
            $this.GetOneXmlElementValue(
                $XmlElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "timeSignature"))

        # Optional 'tempoMarking' element
        if ($XmlElement.tempoMarking)
        {
            $this.TempoMarking = (
                $this.GetOneXmlElementValue(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "tempoMarking"))
        }

        # Optional 'incipit' element
        if ($XmlElement.incipit)
        {
            $this.Incipit = (
                $this.GetOneXmlElementValue(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "incipit"))
        }
        
        # Optional 'characters' element (collection of 'character' elements)
        if ($XmlElement.characters)
        {
            $this.BuildCharacters(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "characters"))     
        }

        # Optional 'lyricists' element (collection of 'lyricist' elements)
        if ($XmlElement.lyricists)
        {
            $this.BuildLyricists(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "lyricists"))     
        }
        
        # Optional 'key' element
        if ($XmlElement.key)
        {
            $this.Key = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "key"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # Mandatory 'instruments' element (collection of 'instrument' elements)
        $this.BuildInstruments(
            $this.GetOneXmlElement(
                $XmlElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "instruments"))

        # Mandatory 'forms' element (collection of 'form' elements)
        $this.BuildForms(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "forms"))
    
        # Optional 'catalogIds' element
        if ($XmlElement.catalogIds)
        {
            $this.BuildCatalogIds(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "catalogIds"))
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

    # Sub-constructor for the 'forms' element
    [void] BuildForms([System.Xml.XmlElement] $FormsElement)
    {
        $this.GetOneOrManyXmlElement(
            $FormsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "form"
        ) | foreach {
                $this.Forms += [EntityFactory]::GetEntity(
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
        
    # Sub-constructor for the 'lyricists' element
    [void] BuildLyricists([System.Xml.XmlElement] $LyricistsElement)
    {
        $this.GetOneOrManyXmlElement(
            $LyricistsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "lyricist"
        ) | foreach {
                $this.Lyricists += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Updates the parent section after the instance was constructed.
    [void] UpdateParentSection([UmsBaeProduct] $ParentSection)
    {
        if ($this.ParentSection -eq $null)
        {
            $this.ParentSection  = $ParentSection
        }
    }

    # Returns the full string representation of the movement. The full string
    # representation includes a prefix with the hierarchy of parent sections,
    # and the regular output of the ToString() method of the current movement.
    [string] ToFullString()
    {
        $_string = ""

        $_string += $this.ParentSection.ToFullString()
        $_string += ([UmsAeEntity]::NonBreakingSpace)
        $_string += $this.ToString()

        return $_string
    }

    # Builds the full title of a music movement
    [string] ToString()
    {
        $_string = ""
        $_addSpace = $false

        # Show labels of all musical forms
        if (([UmsMceMovement]::ShowMusicalForm) -and ($this.Forms))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get an array of form labels
            $_forms = @()
            foreach ($_form in $this.Forms)
                { $_forms += $_form.Label.FullLabel }

            # Add form names to the buffer
            $_string += ([UmsMceMovement]::FormListPrefix)
            $_string += ($_forms -join([UmsMceMovement]::FormDelimiter))
            $_string += ([UmsMceMovement]::FormListSuffix)
            $_addSpace = $true
        }

        # Show musical key
        if (([UmsMceMovement]::ShowMusicalKey) -and ($this.Key))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get key value
            if ([UmsMceMovement]::PreferShortKeys)
                { $_key = $this.Key.Label.ShortLabel }
            else
                { $_key = $this.Key.Label.FullLabel }

            # Add musical key to the buffer
            $_string += ([UmsMceMovement]::KeyListPrefix)
            $_string += $_key
            $_string += ([UmsMceMovement]::KeyListSuffix)
            $_addSpace = $true
        }

        # Show character list
        if (([UmsMceMovement]::ShowCharacterList) -and ($this.Characters))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Get an array of character names
            $_characters = @()
            foreach ($_character in $this.Characters)
                { $_characters += $_character.Name.ShortName }

            # Add musical key to the buffer
            $_string += ([UmsMceMovement]::CharacterListPrefix)
            $_string += ($_characters -join(
                [UmsMceMovement]::CharacterDelimiter))
            $_string += ([UmsMceMovement]::CharacterListSuffix)
            $_addSpace = $true
        }

        # Show movement title infix
        $_string += ([UmsMceMovement]::MovementTitleInfix)
        $_addSpace = $true

        # Include movement title, it defined. We use the ToString() method
        # from the UmsBaeProduct base type to get the string.
        $_fullTitle = ([UmsBaeProduct] $this).ToString()
        if (([UmsMceMovement]::ShowMovementTitle) -and ($_fullTitle))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Add movement title to the buffer
            $_string += $_fullTitle
            $_addSpace = $true
        }

        # Show tempo markings
        if (([UmsMceMovement]::ShowTempoMarking) -and ($this.TempoMarking))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Add tempo marking to the buffer
            $_string += ([UmsMceMovement]::TempoMarkingListPrefix)
            $_string += $this.TempoMarking
            $_string += ([UmsMceMovement]::TempoMarkingListSuffix)
            $_addSpace = $true
        }

        # Show incipit
        if (([UmsMceMovement]::ShowMovementIncipit) -and ($this.Incipit))
        {
            # Add space, if needed
            if ($_addSpace) { $_string += ([UmsAeEntity]::NonBreakingSpace) }

            # Add incipit to the buffer
            $_string += ([UmsMceMovement]::IncipitPrefix)
            $_string += $this.Incipit
            $_string += ([UmsMceMovement]::IncipitSuffix)
            $_addSpace = $true
        }

        return $_string
    }
}