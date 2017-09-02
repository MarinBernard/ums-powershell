###############################################################################
#   Class VorbisCommentConverter
#==============================================================================
#
#   This helper class offers methods to convert UMS metadata to Vorbis Comment.
#
###############################################################################

class VorbisCommentConverter : ForeignMetadataConverter
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Catalog of namespace URIs for all instances.
    static [hashtable] $NamespaceUri = @{
        "Base"  = ([ConfigurationStore]::GetSchemaItem("Base")).Namespace;
        "Audio" = ([ConfigurationStore]::GetSchemaItem("Audio")).Namespace;
        "Music" = ([ConfigurationStore]::GetSchemaItem("Music")).Namespace;
    }

    # The non-breaking space character constant
    static [string] $NonBreakingSpace = $([char] 0x00A0)

    # Whether the first letter of a musical key must be capitalized.
    static [string] $MusicalKeyCapitalizeFirstLetter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicalKeyCapitalizeFirstLetter").Value);

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [hashtable] $Features = @{
        DynamicAlbums                               =   $false;
        ComposerAsArtist                            =   $false;
        ConductorAsArtist                           =   $false;
        EnsembleAsArtist                            =   $false;
        EnsembleAsArtistInstrumentSuffix            =   $false;
        EnsembleInstrumentSuffix                    =   $false;
        InstrumentalistAsArtist                     =   $true;
        InstrumentalistAsArtistInstrumentSuffix     =   $false;
        InstrumentalistAsPerformer                  =   $true;
        InstrumentalistAsPerformerInstrumentSuffix  =   $true;
        InstrumentalistInstrumentSuffix             =   $false;
        LyricistAsArtist                            =   $false;
        MusicalFormAsGenre                          =   $false;
        MusicalStyleAsGenre                         =   $false;
    }

    # Rendering options for dynamic albums
    [hashtable] $DynamicAlbumRendering = @{
        # When dynamic albums are enabled, the composer of the performed work
        # is used as an album artist. When a work has several composers, the
        # names of these composers are merged into a single album artist
        # comment. This string will be inserted between each composer name.
        AlbumArtistDelimiter        =   " & ";
        # If set to $true, dynamic album artist will be created from
        # sort-friendly variants of composer names. If set to false, full
        # composer names will be used instead.
        AlbumArtistUseSortVariants  =   $true;
    }

    # Rendering options
    [hashtable] $Rendering = @{
        # A prefix which will be inserted before the name of a musical form
        # when it is rendered as a GENRE Vorbis Comment. Use this prefix to
        # group musical forms together in the genre list.
        MusicalFormAsGenrePrefix        =   "";
        # A prefix which will be inserted before the name of a musical style
        # when it is rendered as a GENRE Vorbis Comment. Use this prefix to
        # group musical styles together in the genre list.
        MusicalStyleAsGenrePrefix       =   "";
        # If set to $true, the first letter of a musical key will be
        # capitalized.
        MusicalKeyCapitalizeFirstLetter =   $true;
    }

    # Default Vorbis Comment labels.
    # May be altered by configuration values passed to the constructor.
    [hashtable] $VorbisLabels = @{
        AlbumArtist                     =   "ALBUMARTIST"
        AlbumFullTitle                  =   "ALBUM";
        AlbumSortTitle                  =   "ALBUMSORT";
        AlbumSubtitle                   =   "";
        ArtistFullName                  =   "ARTIST";
        ArtistShortName                 =   "ARTISTSHORT";
        ArtistSortName                  =   "ARTISTSORT";
        Asin                            =   "ASIN";
        Barcode                         =   "BARCODE";
        ComposerFullName                =   "COMPOSER";
        ComposerShortName               =   "COMPOSERSHORT";
        ComposerSortName                =   "COMPOSERSORT";
        ConductorFullName               =   "CONDUCTOR";
        ConductorShortName              =   "CONDUCTORSHORT";
        ConductorSortName               =   "CONDUCTORSORT";
        DateFull                        =   "DATE";
        DateYear                        =   "YEAR";
        Ean                             =   "EAN";
        EnsembleFullLabel               =   "ENSEMBLE";
        EnsembleShortLabel              =   "ENSEMBLESHORT";
        EnsembleSortLabel               =   "ENSEMBLESORT";
        Genre                           =   "GENRE";
        Incipit                         =   "INCIPIT";
        InstrumentalistFullName         =   "INSTRUMENTALIST";
        InstrumentalistShortName        =   "INSTRUMENTALISTSHORT";
        InstrumentalistSortName         =   "INSTRUMENTALISTSORT";
        LabelFullLabel                  =   "LABEL";
        LyricistFullName                =   "LYRICIST";
        LyricistShortName               =   "LYRICISTSHORT";
        LyricistSortName                =   "LYRICISTSORT";
        MediumNumberCombined            =   "DISC";
        MediumNumberSimple              =   "DISCNUMBER";
        MediumTotal                     =   "DISCTOTAL";
        MovementMusicalKey              =   "KEY";
        MusicalCatalogId                =   "CATALOGID";
        MusicalForm                     =   "MUSICALFORM";
        MusicalStyle                    =   "STYLE";
        OriginalAlbumArtist             =   "ORIGINALALBUMARTIST";
        OriginalAlbumFullTitle          =   "ORIGINALALBUM";
        OriginalAlbumSortTitle          =   "ORIGINALALBUMSORT";
        OriginalAlbumSubtitle           =   "ORIGINALALBUMSUBTITLE";
        OriginalDateFull                =   "ORIGINALDATE";
        OriginalDateYear                =   "ORIGINALYEAR";
        OriginalMediumNumberCombined    =   "ORIGINALDISC";
        OriginalMediumNumberSimple      =   "ORIGINALDISCNUMBER";
        OriginalMediumTotal             =   "ORIGINALDISCTOTAL";
        OriginalPlace                   =   "ORIGINALPLACE";
        OriginalTrackNumberCombined     =   "ORIGINALTRACK";
        OriginalTrackNumberSimple       =   "ORIGINALTRACKNUMBER";
        OriginalTrackFullTitle          =   "ORIGINALTITLE";
        OriginalTrackSortTitle          =   "ORIGINALTITLESORT";
        OriginalTrackSubtitle           =   "ORIGINALSUBTITLE";
        OriginalTrackTotal              =   "ORIGINALTRACKTOTAL";
        PerformanceDateFull             =   "PERFORMANCEDATE";
        PerformanceDateYear             =   "PERFORMANCEYEAR";
        PerformancePlace                =   "PERFORMANCEPLACE";
        PerformerFullName               =   "PERFORMER";
        PerformerShortName              =   "PERFORMERSHORT";
        PerformerSortName               =   "PERFORMERSORT";
        Place                           =   "PLACE";
        TrackFullTitle                  =   "TITLE";
        TrackNumberCombined             =   "TRACK";
        TrackNumberSimple               =   "TRACKNUMBER";
        TrackSortTitle                  =   "TITLESORT";
        TrackSubtitle                   =   "SUBTITLE";
        TrackTotal                      =   "TRACKTOTAL";
        WorkFullTitle                   =   "WORK";
        WorkMusicalKey                  =   "MAINKEY";
        WorkSortTitle                   =   "WORKSORT";
        WorkSubtitle                    =   "WORKSUBTITLE";
    }

    ###########################################################################
    # Constructors
    ###########################################################################

    # Default constructor. Initializes converter options.
    VorbisCommentConverter([object[]] $Options) : base()
    {
        foreach ($_option in $Options)
        {
            # Optional features
            if ($_option.Name -like "feature-*")
            {
                $_label = $_option.Name.
                    Replace("feature-", "").
                    Replace("-", "")
                if ($this.Features.ContainsKey($_label))
                {
                    $this.Features[$_label] = $_option.Value
                }
            }

            # Rendering options for dynamic albums
            if ($_option.Name -like "dynamic-album-rendering-*")
            {
                $_label = $_option.Name.
                    Replace("dynamic-album-rendering-", "").
                    Replace("-", "")
                if ($this.DynamicAlbumRendering.ContainsKey($_label))
                {
                    $this.DynamicAlbumRendering[$_label] = $_option.Value
                }
            }

            # Rendering options
            if ($_option.Name -like "rendering-*")
            {
                $_label = $_option.Name.
                    Replace("rendering-", "").
                    Replace("-", "")
                if ($this.Rendering.ContainsKey($_label))
                {
                    $this.Rendering[$_label] = $_option.Value
                }
            }

            # Vorbis labels
            elseif ($_option.Name -like "vorbis-label-*")
            {
                $_label = $_option.Name.
                    Replace("vorbis-label-", "").
                    Replace("-", "")
                if ($this.VorbisLabels.ContainsKey($_label))
                {
                    $this.VorbisLabels[$_label] = $_option.Value
                }
            }
        }
    }

    ###########################################################################
    # Concrete implementations of [ForeignMetadataConverter] abstract methods
    #--------------------------------------------------------------------------
    #
    #   Method arguments are typeless since we may work on deserialized
    #   metadata, which do not allow static typing.
    #
    ###########################################################################

    # Main entry point. This method acts as a dispatch box, routing conversion
    # tasks to a more specific subconversion method.
    # Implements an abstract method from the [ForeignMetadataConverter] class.
    # Parameters:
    #   - $Metadata is either a UMS entity or a deserialized UMS entity.
    #       We use the generic object type as static typing is impossible in
    #       such a context.
    # Throws:
    #   - [FMCConversionFailureException] on conversion failure.
    [PSCustomObject[]] Convert([object] $Metadata)
    {
        [PSCustomObject] $_objects = @()

        switch ($Metadata.XmlNamespaceUri)
        {
            ([VorbisCommentConverter]::NamespaceUri).Audio
            {
                switch ($Metadata.XmlElementName)
                {
                    "albumTrackBinding"
                    {
                        $_objects += (
                            $this.ConvertUmsAbeAlbumTrackBinding($Metadata))
                    }

                    default
                    {
                        [EventLogger]::LogError($(
                            "The document element has the following " + `
                            "local name, which is not supported: {0}") `
                            -f $Metadata.XmlElementName)
                        throw [FMCConversionFailureException]::New()
                    }
                }
            }

            default
            {
                [EventLogger]::LogError($(
                    "The document element belongs to the following " + `
                    "namespace, which is not supported: {0}") `
                    -f $Metadata.XmlNamespaceUri)
                throw [FMCConversionFailureException]::New()
            }
        }

        return $_objects
    }

    ###########################################################################
    #   Subconverters
    #--------------------------------------------------------------------------
    #
    #   Method arguments are typeless since we may work on deserialized
    #   metadata, which do not allow static typing.
    #
    ###########################################################################

    # Converts an album track binding to Vorbis Comment.
    # Parameters:
    #   - $Metadata is either a UMS entity or a deserialized UMS entity.
    #       We use the generic object type as static typing is impossible in
    #       such a context.
    # Throws:
    #   - [FMCConversionFailureException] on conversion failure.
    [PSCustomObject] ConvertUmsAbeAlbumTrackBinding([object] $Metadata)
    {
        [string[]]         $_comments = @()
        [PSCustomObject[]] $_pictures = @()

        $_album  = $Metadata.Album
        $_medium = $Metadata.Medium
        $_track  = $Metadata.Track

        try
        {
            # Build Vorbis Comment statements
            $_comments += $this.RenderAlbumArtist($_album, $_track)
            $_comments += $this.RenderAlbumLabels($_album)
            $_comments += $this.RenderAlbumTitle($_album, $_track)
            $_comments += $this.RenderComposers($_track)
            $_comments += $this.RenderConductors($_track)
            $_comments += $this.RenderDate($_album, $_track)
            $_comments += $this.RenderIncipits($_track)
            $_comments += $this.RenderLyricists($_track)
            $_comments += $this.RenderMediumNumber($_medium, $_album)
            $_comments += $this.RenderMusicalCatalogIds($_track)
            $_comments += $this.RenderMusicalForms($_track)
            $_comments += $this.RenderMusicalKeys($_track)
            $_comments += $this.RenderMusicalStyle($_track)
            $_comments += $this.RenderPerformers($_track)
            $_comments += $this.RenderPlace($_album, $_track)
            $_comments += $this.RenderStandardIds($_album, $_track)
            $_comments += $this.RenderTrackNumber($_track, $_medium, $_album)
            $_comments += $this.RenderTrackTitle($_track)
            $_comments += $this.RenderWork($_track)

            # Build references to album pictures
            $_pictures += $this.ExtractAlbumPictures($_album)
            $_pictures += $this.ExtractMovementPictures($_track.Movements)
            $_pictures += $this.ExtractPerformancePictures($_track.Performance)
            $_pictures += $this.ExtractWorkPictures($_track.Piece.Work)
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMCConversionFailureException]::New()
        }

        return New-Object -Type PSCustomObject -Property @{
            VorbisComment = $_comments;
            Pictures      = $_pictures;
        }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Creates a single album picture as a PSCustomObject
    # Parameters:
    #   - $Type is the type of the picture in the Vorbis Comment specification.
    #   - $Description is a description of the picture.
    #   - $Uri is a URI to the picture.
    [PSCustomObject] CreateAlbumPicture(
        [VorbisCommentPictureType] $Type,
        [string] $Description,
        [System.Uri] $Uri)
    {
        return New-Object -Type PSCustomObject -Property @{
            Type = $Type;
            Description = $Description;
            Uri = $Uri;
        }
    }

    # Creates a single Vorbis Comment as a text string.
    [string] CreateVorbisComment([string] $LabelId, [string] $LabelValue)
    {
        $_vc = ""
        $_sanitizedValue = $LabelValue.Trim()

        # We only return the comment if the label ID is known,
        # if the label is not blank, and if the value is not empty.
        # Else, the comment is silently discarded.
        if (
            ($this.VorbisLabels.ContainsKey($LabelId)) -and
            ($this.VorbisLabels[$LabelId]) -and
            ($_sanitizedValue))
        {
            
            $_vc = $($this.VorbisLabels[$LabelId] + "=" + $_sanitizedValue)
        }

        return $_vc
    }

    ###########################################################################
    #   Renderers
    #--------------------------------------------------------------------------
    #
    #   Renderers build sets of Vorbis Comment sharing the same data domain.
    #
    ###########################################################################

    # Render the album artist to Vorbis Comments. If the DynamicAlbum feature
    # is enabled, the album artist is read from the 'artist' element of the
    # album element. If this feature is disabled, the album artist is built
    # from the composers of the performed work.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderAlbumArtist($AlbumMetadata, $TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Extract album artist
            $_albumArtist = $AlbumMetadata.Artist.ToString()

            # DynamicAlbum mode: use music composers as album artists,
            # and register the real album artist as ORIGINAL*.
            if ($this.Features.DynamicAlbums)
            {
                # Original album artist
                $_res = $this.CreateVorbisComment(
                    "OriginalAlbumArtist", $_albumArtist)
                if ($_res) { $_lines += $_res }

                # Extract composers
                $_composers = $TrackMetadata.Performance.Work.Composers

                [string[]] $_composerNames = @()
                foreach ($_composer in $_composers)
                {
                    if ($this.DynamicAlbumRendering.AlbumArtistUseSortVariants)
                        { $_composerNames += $_composer.Name.SortName }
                    else
                        { $_composerNames += $_composer.Name.FullName }
                }

                # Build album artist string
                $_virtualAlbumArtistFullName = (
                    $_composerNames -join(
                        $this.DynamicAlbumRendering.AlbumArtistDelimiter))

                # Build Vorbis Comment
                $_res = $this.CreateVorbisComment(
                    "AlbumArtist", ($_virtualAlbumArtistFullName))
                if ($_res) { $_lines += $_res }
            }

            # Standard mode: use the 'artist' element.
            else
            {
                $_res = $this.CreateVorbisComment(
                    "AlbumArtist", $_albumArtist)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderAlbumArtist")
        }

        return $_lines
    }

    # Render the title of an audio album to Vorbis Comment. The return value of
    # this method depends on the status of the DynamicAlbums feature. If that
    # feature is disabled, the method returns Vorbis Comments describing the
    # real title of the album. If the feature enabled, the method returns the
    # real title of the album in ORIGINALALBUM VCs, and the title of the
    # performed piece, with included performance data, as as the album title.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderAlbumTitle($AlbumMetadata, $TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Gather real album data
            $_realFullTitle = $AlbumMetadata.Title.FullTitle
            $_realSortTitle = $AlbumMetadata.Title.SortTitle
            $_realSubTitle  = $AlbumMetadata.Title.Subtitle

            # Dynamic mode: output both real album title and virtual title
            if($this.Features.DynamicAlbums)
            {
                $_res = $this.CreateVorbisComment(
                    "OriginalAlbumFullTitle", $_realFullTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalAlbumSortTitle", $_realSortTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalAlbumSubtitle", $_realSubTitle)
                if ($_res) { $_lines += $_res }

                $_performedPieceAsString = $TrackMetadata.Piece.ToString()
                $_res = $this.CreateVorbisComment(
                    "AlbumFullTitle", $_performedPieceAsString)
                if ($_res) { $_lines += $_res }
            }

            # Standard mode: use real album title.
            else
            {
                $_res = $this.CreateVorbisComment(
                    "AlbumFullTitle", $_realFullTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "AlbumSortTitle", $_realSortTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "AlbumSubtitle", $_realSubTitle)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderAlbumTitle")
        }

        return $_lines
    }

    # Render the list of labels associated to an audio album to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderAlbumLabels($AlbumMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            foreach ($_label in $AlbumMetadata.Labels)
            {
                $_res = $this.CreateVorbisComment(
                    "LabelFullLabel", $_label.ToString())
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderAlbumLabels")
        }

        return $_lines
    }

    # Renders the composers of the music work to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderComposers($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            $_composers = $TrackMetadata.Piece.Work.Composers

            foreach ($_composer in $_composers)
            {
                $_fullName  = $_composer.Name.FullName
                $_shortName = $_composer.Name.ShortName
                $_sortName  = $_composer.Name.SortName

                $_res = $this.CreateVorbisComment(
                    "ComposerFullName", $_fullName)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "ComposerShortName", $_shortName)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "ComposerSortName", $_sortName)
                if ($_res) { $_lines += $_res }

                # If composers should be registered as artists, let's do it.
                if($this.Features.ComposerAsArtist)
                {
                    $_res = $this.CreateVorbisComment(
                        "ArtistFullName", $_fullName)
                    if ($_res) { $_lines += $_res }

                    $_res = $this.CreateVorbisComment(
                        "ArtistShortName", $_shortName)
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "ArtistSortName", $_sortName)
                    if ($_res) { $_lines += $_res }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderComposers")
        }

        return $_lines
    } 

    # Renders the conductors of the music performance to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderConductors($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            $_conductors = $TrackMetadata.Performance.Conductors

            foreach ($_conductor in $_conductors)
            {
                $_fullName  = $_conductor.Name.FullName
                $_shortName = $_conductor.Name.ShortName
                $_sortName  = $_conductor.Name.SortName

                $_res = $this.CreateVorbisComment(
                    "ConductorFullName", $_fullName)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "ConductorShortName", $_shortName)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "ConductorSortName", $_sortName)
                if ($_res) { $_lines += $_res }

                # If conductors should be registered as artists, let's do it.
                if($this.Features.ConductorAsArtist)
                {
                    $_res = $this.CreateVorbisComment(
                        "ArtistFullName", $_fullName)
                    if ($_res) { $_lines += $_res }

                    $_res = $this.CreateVorbisComment(
                        "ArtistShortName", $_shortName)
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "ArtistSortName", $_sortName)
                    if ($_res) { $_lines += $_res }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderConductors")
        }

        return $_lines
    }

    # Renders the date and year of release of the album to Vorbis Comment.
    # If the DynamicAlbums feature is enabled, these are set the the date
    # and year of the performance. If that feature is disabled, the converter
    # will use the date and year of the oldest album release.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderDate($AlbumMetadata, $TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Build album release info. We use the oldest release event.
            $_release = (
                $AlbumMetadata.Releases | Sort-Object -Property Date)[0]
            $_releaseDate = Get-Date -Date $_release.Date -Format "yyyy-MM-dd"
            $_releaseYear = Get-Date -Date $_release.Date -Format "yyyy"

            # Build performance date info.
            $_performance = $TrackMetadata.Performance
            $_performanceDate = (
                Get-Date -Date $_performance.Date -Format "yyyy-MM-dd")
            $_performanceYear = (
                Get-Date -Date $_performance.Date -Format "yyyy")

            # If DynamicAlbums are enabled, we use the date of the performance,
            # and render the date of the oldest album release as ORIGINAL* VCs.
            if ($this.Features.DynamicAlbums)
            {
                # Performance date
                $_res = $this.CreateVorbisComment(
                    "DateFull", $_performanceDate)
                if ($_res) { $_lines += $_res }

                # Performance year
                $_res = $this.CreateVorbisComment(
                    "DateYear", $_performanceYear)
                if ($_res) { $_lines += $_res }

                # Original album release date
                $_res = $this.CreateVorbisComment(
                    "OriginalDateFull", $_releaseDate)
                if ($_res) { $_lines += $_res }

                # Original album release year
                $_res = $this.CreateVorbisComment(
                    "OriginalDateYear", $_releaseYear)
                if ($_res) { $_lines += $_res }
            }

            # Else, we use data from the oldest release of the album
            else
            {
                # Release date
                $_res = $this.CreateVorbisComment(
                    "DateFull", $_releaseDate)
                if ($_res) { $_lines += $_res }

                # Release year
                $_res = $this.CreateVorbisComment(
                    "DateYear", $_releaseYear)
                if ($_res) { $_lines += $_res }
            }

            # Performance date and year are alwaus rendered
            $_res = $this.CreateVorbisComment(
                "PerformanceDateFull", $_performanceDate)
            if ($_res) { $_lines += $_res }

            # Performance year
            $_res = $this.CreateVorbisComment(
                "PerformanceDateYear", $_performanceYear)
            if ($_res) { $_lines += $_res }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderDate")
        }

        return $_lines
    }

    # Renders incipits to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderIncipits($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            foreach ($_movement in $TrackMetadata.Movements)
            {
                $_res = $this.CreateVorbisComment(
                    "Incipit", $_movement.Incipit)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderIncipits")
        }

        return $_lines
    } 

    # Renders lyricists to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderLyricists($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            foreach ($_movement in $TrackMetadata.Movements)
            {
                foreach ($_lyricist in $_movement.Lyricists)
                {
                    $_full  = $_lyricist.Name.FullName
                    $_short = $_lyricist.Name.ShortName
                    $_sort  = $_lyricist.Name.SortName

                    $_res = $this.CreateVorbisComment(
                        "LyricistFullName", $_full)
                    if ($_res) { $_lines += $_res }

                    $_res = $this.CreateVorbisComment(
                        "LyricistShortName", $_short)
                    if ($_res) { $_lines += $_res }

                    $_res = $this.CreateVorbisComment(
                        "LyricistSortName", $_sort)
                    if ($_res) { $_lines += $_res }

                    # If lyricists should be registered as artists, let's do it.
                    if($this.Features.LyricistAsArtist)
                    {
                        $_res = $this.CreateVorbisComment(
                            "ArtistFullName", $_full)
                        if ($_res) { $_lines += $_res }

                        $_res = $this.CreateVorbisComment(
                            "ArtistShortName", $_short)
                        if ($_res) { $_lines += $_res }
            
                        $_res = $this.CreateVorbisComment(
                            "ArtistSortName", $_sort)
                        if ($_res) { $_lines += $_res }
                    }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderLyricists")
        }

        return $_lines
    } 

    # Renders the medium number info of an album track to Vorbis Comments.
    # The return value of this method depends on the status of the
    # DynamicAlbums feature. If this feature is disabled, the method returns
    # the number of the medium owning the track on its parent album.
    # If the feature is enabled, real media numbers will be rendered as
    # a set of ORIGINAL* Vorbis Comments. At the difference of track numbers,
    # no virtual medium number will be created: media numbers will be disabled
    # as tracks are all consolidated into performance groups.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderMediumNumber($MediumMetadata, $AlbumMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Get real track numbers
            $_realMediumNumber = $MediumMetadata.Number.ToString()
            $_realMediumTotal = $AlbumMetadata.Media.Count.ToString()
            $_realCombined = $($_realMediumNumber + "/" + $_realMediumTotal)

            # Dynamic mode: render real medium numbers to ORIGINAL* VCs
            if($this.Features.DynamicAlbums)
            {
                $_res = $this.CreateVorbisComment(
                    "OriginalMediumNumberCombined", $_realCombined)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalMediumNumberSimple", $_realMediumNumber)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalMediumTotal", $_realMediumTotal)
                if ($_res) { $_lines += $_res }
            }

            # Standard mode: use real medium numbers
            else
            {
                $_res = $this.CreateVorbisComment(
                    "MediumNumberCombined", $_realCombined)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "MediumNumberSimple", $_realMediumNumber)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "MediumTotal", $_realMediumTotal)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderMediumNumber")
        }

        return $_lines
    }

    # Renders catalog IDs of the music work/movements to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderMusicalCatalogIds($TrackMetadata)
    {
        [string[]] $_lines = @()
        [string[]] $_catalogIds = @()

        try
        {
            # Catalog IDs of the parent work
            foreach ($_catalogId in $TrackMetadata.Piece.Work.CatalogIds)
            {
                $_catalogIds += $_catalogId.ToString()
            }

            # Catalog IDs associated to each movement included in the track
            foreach ($_movement in $TrackMetadata.Movements)
            {
                foreach ($_catalogId in $_movement.CatalogIds)
                {
                    $_catalogIds += $_catalogId.ToString()
                }
            }

            # Create Vorbis Comments
            foreach ($_catalogId in $_catalogIds)
            {
                $_res = $this.CreateVorbisComment(
                    "MusicalCatalogId", $_catalogId)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New(
                "RenderMusicalCatalogIds")
        }

        return $_lines
    }

    # Renders musical forms to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderMusicalForms($TrackMetadata)
    {
        [string[]] $_lines = @()
        [string[]] $_forms = @()

        try
        {
            # Musical form associated to the parent work.
            $_forms += $TrackMetadata.Piece.Work.Form

            # Musical forms associated to each movement included in the track
            foreach ($_movement in $TrackMetadata.Movements)
            {
                foreach ($_form in $_movement.Forms)
                {
                    $_forms += $_form.ToString()
                }
            }

            # Create Vorbis Comments
            foreach ($_form in $_forms)
            {
                $_res = $this.CreateVorbisComment(
                    "MusicalForm", $_form)
                if ($_res) { $_lines += $_res }

                # If forms should be registered as genres, let's do it.
                if($this.Features.MusicalFormAsGenre)
                {
                    $_fullForm = $(
                        $this.Rendering.MusicalFormAsGenrePrefix + $_form)
                    
                    $_res = $this.CreateVorbisComment(
                        "Genre", $_fullForm)
                    if ($_res) { $_lines += $_res }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderMusicalForms")
        }

        return $_lines
    }

    # Renders musical keys to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderMusicalKeys($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Main key of the parent work.
            $_rawKey = $TrackMetadata.Piece.Work.Key.ToString()
            if ([VorbisCommentConverter]::MusicalKeyCapitalizeFirstLetter)
            {
                $_key = $(
                    $_rawKey.Substring(0, 1).ToUpper() + $_rawKey.Substring(1))
            }
            else
                { $_key = $_rawKey }
            
            $_res = $this.CreateVorbisComment(
                "WorkMusicalKey", $_key)
            if ($_res) { $_lines += $_res }

            # Musical keys associated to each movement included in the track
            foreach ($_movement in $TrackMetadata.Movements)
            {
                # Main key of the parent work.
                $_rawKey = $_movement.Key.ToString()
                if ([VorbisCommentConverter]::MusicalKeyCapitalizeFirstLetter)
                {
                    $_key = $(
                        $_rawKey.Substring(0, 1).ToUpper() + $_rawKey.Substring(1))
                }
                else
                    { $_key = $_rawKey }

                $_res = $this.CreateVorbisComment(
                    "MovementMusicalKey", $_key)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderMusicalKeys")
        }

        return $_lines
    }

    # Renders musical styles to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderMusicalStyle($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Musical style associated to the parent work.
            $_style = $TrackMetadata.Piece.Work.Style.ToString()

            $_res = $this.CreateVorbisComment(
                "MusicalStyle", $_style)
            if ($_res) { $_lines += $_res }

            # If styles should be registered as genres, let's do it.
            if($this.Features.MusicalStyleAsGenre)
            {
                $_fullStyle = $(
                    $this.Rendering.MusicalStyleAsGenrePrefix + $_style)
                
                $_res = $this.CreateVorbisComment(
                    "Genre", $_fullStyle)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderMusicalStyle")
        }

        return $_lines
    }

    # Renders the performers of a music performance to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderPerformers($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            $_performers = $TrackMetadata.Performance.Performers

            foreach ($_performer in $_performers)
            {
                # Gather instrument suffix
                [string] $_instrumentSuffix = $(
                    [VorbisCommentConverter]::NonBreakingSpace + `
                    $_performer.PlayedInstrumentSuffix)

                # If the performer is an ensemble
                if ($_performer.Ensemble)
                {
                    # Gather data
                    [string] $_full  = $_performer.Ensemble.Label.FullLabel
                    [string] $_short = $_performer.Ensemble.Label.ShortLabel
                    [string] $_sort  = $_performer.Ensemble.Label.SortLabel

                    # Assign optional instrument suffix
                    if($this.Features.EnsembleInstrumentSuffix)
                        { [string] $_suffix = $_instrumentSuffix }
                    else
                        { [string] $_suffix = "" }

                    # Create Vorbis Comment
                    $_res = $this.CreateVorbisComment(
                        "EnsembleFullLabel", $($_full + $_suffix))
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "EnsembleShortLabel", $($_short + $_suffix))
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "EnsembleSortLabel", $($_sort + $_suffix))
                    if ($_res) { $_lines += $_res }

                    # If ensembles should be registered as artists, let's do it
                    if($this.Features.EnsembleAsArtist)
                    {
                        # Assign optional instrument suffix
                        if($this.Features.EnsembleAsArtistInstrumentSuffix)
                            { [string] $_suffix = $_instrumentSuffix }
                        else
                            { [string] $_suffix = "" }
                        
                        $_res = $this.CreateVorbisComment(
                            "ArtistFullName", $($_full + $_suffix))
                        if ($_res) { $_lines += $_res }

                        $_res = $this.CreateVorbisComment(
                            "ArtistShortName", $($_short + $_suffix))
                        if ($_res) { $_lines += $_res }
            
                        $_res = $this.CreateVorbisComment(
                            "ArtistSortName", $($_sort + $_suffix))
                        if ($_res) { $_lines += $_res }
                    }
                }

                # If the performer is an instrumentalist
                elseif ($_performer.Instrumentalist)
                {
                    # Gather data
                    [string] $_full  = $_performer.Instrumentalist.Name.FullName
                    [string] $_short = $_performer.Instrumentalist.Name.ShortName
                    [string] $_sort  = $_performer.Instrumentalist.Name.SortName

                    # Assign optional instrument suffix
                    if($this.Features.InstrumentalistInstrumentSuffix)
                        { [string] $_suffix = $_instrumentSuffix }
                    else
                        { [string] $_suffix = "" }

                    # Create Vorbis Comment
                    $_res = $this.CreateVorbisComment(
                        "InstrumentalistFullName", $($_full + $_suffix))
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "InstrumentalistShortName", $($_short + $_suffix))
                    if ($_res) { $_lines += $_res }
        
                    $_res = $this.CreateVorbisComment(
                        "InstrumentalistSortName", $($_sort + $_suffix))
                    if ($_res) { $_lines += $_res }

                    # If instrumentalists should be registered as performers,
                    # let's do it.
                    if($this.Features.InstrumentalistAsPerformer)
                    {
                        # Assign optional instrument suffix
                        if($this.Features.
                            InstrumentalistAsPerformerInstrumentSuffix)
                        {
                            [string] $_suffix = $_instrumentSuffix
                        }
                        else
                        {
                            [string] $_suffix = ""
                        }
                        
                        $_res = $this.CreateVorbisComment(
                            "PerformerFullName", $($_full + $_suffix))
                        if ($_res) { $_lines += $_res }

                        $_res = $this.CreateVorbisComment(
                            "PerformerShortName", $($_short + $_suffix))
                        if ($_res) { $_lines += $_res }
            
                        $_res = $this.CreateVorbisComment(
                            "PerformerSortName", $($_sort + $_suffix))
                        if ($_res) { $_lines += $_res }
                    }

                    # If instrumentalists should be registered as artists,
                    # let's do it.
                    if($this.Features.InstrumentalistAsArtist)
                    {
                        # Assign optional instrument suffix
                        if ($this.Features.
                            InstrumentalistAsArtistInstrumentSuffix)
                        {
                            [string] $_suffix = $_instrumentSuffix
                        }
                        else
                        {
                            [string] $_suffix = ""
                        }
                        
                        $_res = $this.CreateVorbisComment(
                            "ArtistFullName", $($_full + $_suffix))
                        if ($_res) { $_lines += $_res }

                        $_res = $this.CreateVorbisComment(
                            "ArtistShortName", $($_short + $_suffix))
                        if ($_res) { $_lines += $_res }
            
                        $_res = $this.CreateVorbisComment(
                            "ArtistSortName", $($_sort + $_suffix))
                        if ($_res) { $_lines += $_res }
                    }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderPerformers")
        }

        return $_lines
    }

    # Renders place data to Vorbis Comment. If the DynamicAlbums feature is
    # enabled, this method renders the performance place. If this feature
    # is disabled, the method renders the place linked to the oldest release
    # event in the album Releases collection.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderPlace($AlbumMetadata, $TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Build album release info. We use the oldest release event.
            $_release = (
                $AlbumMetadata.Releases | Sort-Object -Property Date)[0]
            $_releasePlace = $_release.Place.ToString()

            # Build performance place
            $_performance = $TrackMetadata.Performance
            $_performancePlace = $_performance.Place.ToString()

            # If DynamicAlbums are enabled, we use the date of the performance,
            # and render the date of the oldest album release into ORIGINAL* VCs.
            if ($this.Features.DynamicAlbums)
            {
                # Performance place
                $_res = $this.CreateVorbisComment(
                    "Place", $_performancePlace)
                if ($_res) { $_lines += $_res }

                # Original album release place
                $_res = $this.CreateVorbisComment(
                    "OriginalPlace", $_releasePlace)
                if ($_res) { $_lines += $_res }
            }

            # Else, we use data from the oldest release of the album
            else
            {
                # Release place
                $_res = $this.CreateVorbisComment(
                    "Place", $_releasePlace)
                if ($_res) { $_lines += $_res }
            }

            # Performance place is always rendered
            $_res = $this.CreateVorbisComment(
                "PerformancePlace", $_performancePlace)
            if ($_res) { $_lines += $_res }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderPlace")
        }

        return $_lines
    }

    # Renders standard IDs to Vorbis Comment. This includes barcode and ASIN.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderStandardIds($AlbumMetadata, $TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            foreach ($_standardId in $AlbumMetadata.StandardIds)
            {
                switch ($_standardId.Standard.Uid)
                {
                    "ASIN"
                    {
                        $_res = $this.CreateVorbisComment(
                            "Asin", $_standardId.Id)
                        if ($_res) { $_lines += $_res }
                    }

                    "EAN/13"
                    {
                        $_res = $this.CreateVorbisComment(
                            "Barcode", $_standardId.Id)
                        if ($_res) { $_lines += $_res }

                        $_res = $this.CreateVorbisComment(
                            "Ean", $_standardId.Id)
                        if ($_res) { $_lines += $_res }
                    }
                }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderStandardIds")
        }

        return $_lines
    }

    # Render the track number info of an album track to Vorbis Comment.
    # The return value of this method depends on the status of the
    # DynamicAlbums feature. If this feature is disabled, the method returns
    # the real track number of the track on its parent album. If the feature
    # is enabled, it returns Vorbis Comments describing the order of appearance
    # of the track in the music performance. The real track number is returned
    # as a set of ORIGINALTRACKNUM VCs.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderTrackNumber(
        $TrackMetadata,
        $MediumMetadata,
        $AlbumMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Get real track numbers
            $_realTrackNumber = $TrackMetadata.Number.ToString()
            $_realTrackTotal = $MediumMetadata.Tracks.Count.ToString()
            $_realCombined = $($_realTrackNumber + "/" + $_realTrackTotal)

            # Dynamic mode: use both real and virtual track numbers
            if($this.Features.DynamicAlbums)
            {
                $_res = $this.CreateVorbisComment(
                    "OriginalTrackNumberCombined", $_realCombined)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalTrackNumberSimple", $_realTrackNumber)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalTrackTotal", $_realTrackTotal)
                if ($_res) { $_lines += $_res }

                # Get the list of all tracks linked to the same piece in the
                # same performance. We explicitely sort media and tracks to get
                # an ordered array of album tracks.
                [Object[]] $_tracks = @()

                foreach ($_medium in (
                    $AlbumMetadata.Media | Sort-Object -Property Number))
                {
                    foreach ($_track in (
                        $_medium.Tracks | Sort-Object -Property Number))
                    {
                        if ($_track.Piece -eq $TrackMetadata.Piece)
                        {
                            $_tracks += $_track
                        }
                    }
                }

                # Locate current track in the array and use the index as a track
                # number. Total tracks is equal to the size of the array.
                $_trackNumber = ($_tracks.IndexOf($TrackMetadata) + 1).ToString()
                $_trackTotal  = ($_tracks.Count).ToString()
                $_combined    = $($_trackNumber + "/" + $_trackTotal)

                # Output Vorbis Comments
                $_res = $this.CreateVorbisComment(
                    "TrackNumberCombined", $_combined)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackNumberSimple", $_trackNumber)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackTotal", $_trackTotal)
                if ($_res) { $_lines += $_res }
            }

            # Standard mode: use real track number.
            else
            {
                $_res = $this.CreateVorbisComment(
                    "TrackNumberCombined", $_realCombined)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackNumberSimple", $_realTrackNumber)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackTotal", $_realTrackTotal)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderTrackNumbers")
        }

        return $_lines
    }

    # Render the title of an album track to Vorbis Comment. The return value of
    # this method depends on the status of the DynamicAlbums feature. If that
    # feature is disabled, the method returns Vorbis Comments describing the
    # real title of the track. If the feature enabled, the method returns the
    # real title of the track in ORIGINALTITLE VCs, and the movement title
    # as a the actual track title.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderTrackTitle($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            # Gather real album data
            $_realFullTitle = $TrackMetadata.Title.FullTitle
            $_realSortTitle = $TrackMetadata.Title.SortTitle
            $_realSubTitle  = $TrackMetadata.Title.Subtitle

            # Dynamic mode: output both real and virtual track titles
            if($this.Features.DynamicAlbums)
            {
                $_res = $this.CreateVorbisComment(
                    "OriginalTrackFullTitle", $_realFullTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalTrackSortTitle", $_realSortTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "OriginalTrackSubtitle", $_realSubTitle)
                if ($_res) { $_lines += $_res }

                $_trackString = $TrackMetadata.ToString()
                $_res = $this.CreateVorbisComment(
                    "TrackFullTitle", $_trackString)
                if ($_res) { $_lines += $_res }
            }

            # Standard mode: use real track title.
            else
            {
                $_res = $this.CreateVorbisComment(
                    "TrackFullTitle", $_realFullTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackSortTitle", $_realSortTitle)
                if ($_res) { $_lines += $_res }

                $_res = $this.CreateVorbisComment(
                    "TrackSubtitle", $_realSubTitle)
                if ($_res) { $_lines += $_res }
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderTrackTitle")
        }

        return $_lines
    }

    # Renders the performed work to Vorbis Comment.
    # Throws:
    #   - [VCCRendererFailureException] on failure.
    [string[]] RenderWork($TrackMetadata)
    {
        [string[]] $_lines = @()

        try
        {
            $_work = $TrackMetadata.Piece.Work

            $_full  = $_work.Title.FullTitle
            $_sort  = $_work.Title.SortTitle
            $_sub   = $_work.Title.Subtitle

            $_res = $this.CreateVorbisComment(
                "WorkFullTitle", $_full)
            if ($_res) { $_lines += $_res }

            $_res = $this.CreateVorbisComment(
                "WorkSortTitle", $_sort)
            if ($_res) { $_lines += $_res }

            $_res = $this.CreateVorbisComment(
                "WorkSubtitle", $_sub)
            if ($_res) { $_lines += $_res }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCCRendererFailureException]::New("RenderWork")
        }

        return $_lines
    }

    ###########################################################################
    #   Picture extractors
    #--------------------------------------------------------------------------
    #
    #   Picture extractors extract references to album pictures from the
    #   supplied metadata.
    #
    ###########################################################################

    # Extracts pictures related to an audio album, such as front and back
    # covers, leaflet pages and media pictures.
    [PSCustomObject[]] ExtractAlbumPictures($AlbumMetadata)
    {
        [PSCustomObject[]] $_pictures = @()

        foreach( $_picture in $AlbumMetadata.Pictures)
        {
            switch ($_picture.PictureType)
            {
                "back-cover"
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::BackCover,
                        "Back cover",
                        $_picture.Uri.AbsoluteUri)
                }

                "front-cover"
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::FrontCover,
                        "Front cover",
                        $_picture.Uri.AbsoluteUri)
                }

                "leaflet-page"
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::LeafletPage,
                        "Leaflet page",
                        $_picture.Uri.AbsoluteUri)
                }

                "media"
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::Media,
                        "Media",
                        $_picture.Uri.AbsoluteUri)
                }
            }
        }

        return $_pictures
    }

    # Extracts pictures related to a music movement, such as pictures of
    # lyricists.
    [PSCustomObject[]] ExtractMovementPictures($MovementMetadata)
    {
        [PSCustomObject[]] $_pictures = @()

        foreach( $_movement in $MovementMetadata)
        {
            foreach ($_lyricist in $_movement.lyricists)
            {
                $_validPictureTypes = @("portrait")

                foreach ($_picture in $_lyricist.Pictures)
                {
                    if ($_validPictureTypes -contains($_picture.PictureType))
                    {
                        $_pictures += $this.CreateAlbumPicture(
                            [VorbisCommentPictureType]::Lyricist,
                            $_lyricist.ToString(),
                            $_picture.Uri.AbsoluteUri)
                    }
                }
            }
        }

        return $_pictures
    }

    # Extracts pictures related to a music performance, such as pictures of
    # music ensembles or performers.
    [PSCustomObject[]] ExtractPerformancePictures($PerformanceMetadata)
    {
        [PSCustomObject[]] $_pictures = @()

        # Conductors
        foreach ($_conductor in $PerformanceMetadata.conductors)
        {
            $_validPictureTypes = @("portrait")
            
            foreach ($_picture in $_conductor.Pictures)
            {
                if ($_validPictureTypes -contains($_picture.PictureType))
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::Conductor,
                        $_conductor.ToString(),
                        $_picture.Uri.AbsoluteUri)
                }
            }
        }

        # Performers
        foreach ($_performer in $PerformanceMetadata.performers)
        {
            # Ensembles
            if ($_performer.Ensemble)
            {
                $_validPictureTypes = @("group-photo")

                foreach ($_picture in $_performer.Ensemble.Pictures)
                {
                    if ($_validPictureTypes -contains($_picture.PictureType))
                    {
                        $_pictures += $this.CreateAlbumPicture(
                            [VorbisCommentPictureType]::LeadArtist,
                            $_performer.ToString(),
                            $_picture.Uri.AbsoluteUri)
                        
                        $_pictures += $this.CreateAlbumPicture(
                            [VorbisCommentPictureType]::Ensemble,
                            $_performer.ToString(),
                            $_picture.Uri.AbsoluteUri)
                    }
                }
            }

            # Instrumentalists
            elseif ($_performer.Instrumentalist)
            {
                $_validPictureTypes = @("portrait")

                foreach ($_picture in $_performer.Instrumentalist.Pictures)
                {
                    if ($_validPictureTypes -contains($_picture.PictureType))
                    {
                        $_pictures += $this.CreateAlbumPicture(
                            [VorbisCommentPictureType]::LeadArtist,
                            $_performer.ToString(),
                            $_picture.Uri.AbsoluteUri)

                        $_pictures += $this.CreateAlbumPicture(
                            [VorbisCommentPictureType]::Artist,
                            $_performer.ToString(),
                            $_picture.Uri.AbsoluteUri)
                    }
                }
            }
        }

        return $_pictures
    }

    # Extracts pictures related to a music work, such as pictures of composers.
    [PSCustomObject[]] ExtractWorkPictures($WorkMetadata)
    {
        [PSCustomObject[]] $_pictures = @()

        foreach ($_composer in $WorkMetadata.composers)
        {
            $_validPictureTypes = @("portrait")

            foreach ($_picture in $_composer.Pictures)
            {
                if ($_validPictureTypes -contains($_picture.PictureType))
                {
                    $_pictures += $this.CreateAlbumPicture(
                        [VorbisCommentPictureType]::Composer,
                        $_composer.ToString(),
                        $_picture.Uri.AbsoluteUri)
                }
            }
        }

        return $_pictures
    }
}

###############################################################################
#   Enum VorbisCommentPictureType
#==============================================================================
#
#   This enum defines friendly names for each type of album art picture which
#   may be embedded into a Xiph.org container. The order of this enum type
#   follows the specifications of the container format: the integer of each
#   enum entry matches the integer expected by metaflac.
#
###############################################################################

Enum VorbisCommentPictureType
{
    Other
    FileIcon
    OtherIcon
    FrontCover
    BackCover
    LeafletPage
    Media
    LeadArtist
    Artist
    Conductor
    Ensemble
    Composer
    Lyricist
    RecordingLocation
    RecordingSnapshot
    PerformanceSnapshot
    ScreenCapture
    Fish
    Illustration
    ArtistLogo
    PublisherLogo
}