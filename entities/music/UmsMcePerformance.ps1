###############################################################################
#   Concrete entity class UmsMcePerformance
#==============================================================================
#
#   This class describes a music performance event entity, built from an
#   'performance' XML element from the music namespace. This describes the date
#   and place at which a performance of a music work took place. This entity
#   also includes a reference to an instance of UmsMceWork describing the
#   performed work.
#   This entity inherits the UmsMaeEvent class rather that the UmsBaeEvent
#   class. This means it supports specifying a musical venue as an event place.
#
###############################################################################

class UmsMcePerformance : UmsMaeEvent
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # One or several characters which will be inserted between each name
    # in a list of music composers.
    static [string] $ComposerListDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformanceComposerListDelimiter").Value)
    
    # One or several characters which will be inserted before a list of
    # music composers.
    static [string] $ComposerListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformanceComposerListPrefix").Value)

    # One or several characters which will be inserted after a list of
    # music composers.
    static [string] $ComposerListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformanceComposerListSuffix").Value)

    # One or several characters which will be inserted between the titles of
    # each performed piece in the performance title.
    static [string] $PieceTitleDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformancePieceTitleDelimiter").Value)

    # The maximal number of titles of performed pieces that will be included in
    # the performance title.
    static [int] $PieceTitleMaxCount = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformancePieceTitleMaxCount").Value)

    # One or several characters which will be inserted between each name
    # in a list of music performers.
    static [string] $PerformerListDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerListDelimiter").Value)
    
    # One or several characters which will be inserted before a list of
    # music performers.
    static [string] $PerformerListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerListPrefix").Value)

    # One or several characters which will be inserted after a list of
    # music performers.
    static [string] $PerformerListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerListSuffix").Value)

    # One or several characters which will be inserted before a the year of a
    # music performance.
    static [string] $PerformanceYearPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalPerformanceYearPrefix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Conductors of the performance
    [UmsMceConductor[]] $Conductors

    # Performers involved in the performance. This includes both music
    # ensembles and single instrumentalists.
    [UmsMcePerformer[]] $Performers

    # A collection of performed pieces. If the performance is a concert, this
    # is the equivalent of the concert programme.
    [UmsMcePiece[]] $Pieces

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMcePerformance([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        [EventLogger]::LogVerbose("Beginning instance construction.")

        try
        {
            # Validate the XML root element
            $this.ValidateXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "performance")

            # Optional 'conductors' element
            if ($XmlElement.conductors)
            {
                $this.BuildConductors(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "conductors"))
            }
            
            # Mandatory 'performers' element (collection of 'performer' elmnts)
            $this.BuildPerformers(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "performers"))

            # Mandatory 'pieces' element (collection of 'piece' elements)
            $this.BuildPieces(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "pieces"))
        }
        
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UEConstructorFailureException]::New()
        }
        
        [EventLogger]::LogVerbose("Finished instance construction.")
    }

    # Sub-constructor for the 'conductors' element
    [void] BuildConductors([System.Xml.XmlElement] $ConductorsElement)
    {
        [EventLogger]::LogVerbose(
            "Beginning to populate the 'Conductors' collection.")

        try
        {
            $this.GetOneOrManyXmlElement(
                $ConductorsElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "conductor"
            ) | foreach {
                    $this.Conductors += [EntityFactory]::GetEntity(
                        $_, $this.SourcePathUri, $this.SourceFileUri) }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New("BuildConductors")
        }

        [EventLogger]::LogVerbose(
            "Finished populating the 'Conductors' collection.")
    }

    # Sub-constructor for the 'performers' element
    [void] BuildPerformers([System.Xml.XmlElement] $PerformersElement)
    {
        [EventLogger]::LogVerbose(
            "Beginning to populate the 'Performers' collection.")

        try
        {
            $this.GetOneOrManyXmlElement(
                $PerformersElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "performer"
            ) | foreach {
                    $this.Performers += [EntityFactory]::GetEntity(
                        $_, $this.SourcePathUri, $this.SourceFileUri) }
        }
        
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New("BuildPerformers")
        }

        [EventLogger]::LogVerbose(
            "Finished populating the 'Performers' collection.")
    }

    # Sub-constructor for the 'pieces' element
    [void] BuildPieces([System.Xml.XmlElement] $PiecesElement)
    {
        [EventLogger]::LogVerbose(
            "Beginning to populate the 'Pieces' collection.")

        try
        {
            $this.GetOneOrManyXmlElement(
                $PiecesElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "piece") | foreach {
                    $this.Pieces += [EntityFactory]::GetEntity(
                        $_, $this.SourcePathUri, $this.SourceFileUri) }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New("BuildPieces")
        }

        [EventLogger]::LogVerbose(
            "Updating parent performance in all 'Piece' instances.")

        foreach ($_piece in $this.Pieces)
            { $_piece.UpdateParentPerformance($this) }

        [EventLogger]::LogVerbose(
            "Finished populating the 'Pieces' collection.")
    }

    ###########################################################################
    # Static piece-related helpers
    ###########################################################################

    # Return a UmsMcePiece instance from the $Pieces collection, whose ID
    # matched the supplied $Id parameter.
    # Throws:
    #   - [UEReferenceNotFoundException] if no piece can be found with the
    #       specified Id.
    #   - [UEDuplicateReferenceException] if several pieces are found with the
    #       same ID.
    static [UmsMcePiece] GetPieceById([UmsMcePiece[]] $Pieces, [string] $Id)
    {
        [EventLogger]::LogVerbose(
            "Asked for a 'UmsMcePiece' instance with the following ID: {0}." `
            -f $Id)
        
        [UmsMcePiece[]] $_results = $Pieces |
            Where-Object { $_.Id -eq $Id }

        if ($_results.Count -eq 0)
        {
            [EventLogger]::LogVerbose("No piece found with the specified ID.")
            throw [UEReferenceNotFoundException]::New(
                "UmsMcePiece", "id", $Id)
        }
        if ($_results.Count -gt 1)
        {
            [EventLogger]::LogVerbose("No piece found with the specified ID.")
            throw [UEDuplicateReferenceException]::New(
                "UmsMcePiece", "id", $Id)
        }

        [EventLogger]::LogVerbose(
            "'UmsMcePiece' instance with ID '{0}' was found and returned." `
            -f $Id)

        return $_results[0]
    }

    ###########################################################################
    # Performance and piece title rendering helpers
    ###########################################################################

    # Renders and returns the second part of a performance or piece title,
    # which contains the names of the performing ensemble and conductor,
    # and the date of the performance.
    [string] RenderPerformanceTitleSuffix()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()

        # Begin performer list
        $_performers = @()
        $_sb.Append([UmsMcePerformance]::PerformerListPrefix)

        # Add ensembles to the performer list
        # Get an array of ensemble short names
        foreach ($_performer in $this.Performers)
        {
            if ($_performer.Ensemble)
            {
                $_ensemble = $_performer.Ensemble
                if ($_ensemble.Label.ShortLabel)
                    { $_performers += $_ensemble.Label.ShortLabel }
                else
                    { $_performers += $_ensemble.Label.FullLabel }
            }
        }

        # Add conductors to the performer list
        # Get an array of conductor short names
        foreach ($_conductor in $this.Conductors)
        {
            if ($_conductor.Name.ShortName)
                { $_performers += $_conductor.Name.ShortName }
            else
                { $_performers += $_conductor.Name.FullName }
        }

        # Add performer names to the buffer
        $_sb.Append($_performers -join(
            [UmsMcePerformance]::PerformerListDelimiter))

        # Include performance year
        if($this.Date)
        {
            $_sb.Append([UmsMcePerformance]::PerformanceYearPrefix)
            $_sb.Append((Get-Date -Date $this.Date -Format "yyyy"))
        }

        # End performer list
        $_sb.Append([UmsMcePerformance]::PerformerListSuffix)

        return $_sb.ToString()
    }

    # Performance to string
    [string] ToString()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()

        # If the number of performed pieces is below the value of the
        # PieceTitleMaxCount variable, we include all piece titles into
        # the performance title.
        if ($this.Pieces.Count -le ([UmsMcePerformance]::PieceTitleMaxCount))
        {
            # Gather piece titles
            [string[]] $_pieceTitles = @()
            foreach ($_piece in $this.Pieces)
            {
                $_pieceTitles += $_piece.GetPieceTitle()
            }

            # Remove duplicates
            $_pieceTitles = $_pieceTitles | Sort-Object -Unique

            # Include piece titles
            $_sb.Append($_pieceTitles -join(
                [UmsMcePerformance]::PieceTitleDelimiter))
        }

        # If the performance includes too many pieces to render all titles,
        # we render a shortened version of the title by showing only composer
        # names.
        else
        {
            # Get the names of all composers involved in the performance.
            [string[]] $_composers = @()
            foreach ($_piece in $this.Pieces)
            {
                foreach ($_composer in $_piece.Work.Composers)
                {
                    $_composers += $_composer.Name.ShortName
                }
            }

            # Remove duplicates.
            $_composers = $_composers | Sort-Object -Unique

            # Add the list of composers
            $_sb.Append([UmsMcePerformance]::ComposerListPrefix)
            $_sb.Append(
                ($_composers -join(
                    [UmsMcePerformance]::ComposerListDelimiter)))
            $_sb.Append([UmsMcePerformance]::ComposerListSuffix)
        }

        # Add performance title suffix
        $_sb.Append([UmsAeEntity]::NonBreakingSpace)
        $_sb.Append($this.RenderPerformanceTitleSuffix())

        return $_sb.ToString()
    }
}