###############################################################################
#   Concrete entity class UmsMceTrack
#==============================================================================
#
#   This class describes a music track entity, built from a 'track' XML
#   element from the music namespace.
#
###############################################################################

class UmsMceTrack : UmsBaeTrack
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether the track title rendered as string should include the title of
    # all the movements comprised in the track. If set to $false, the string
    # will only include the title of the first movement.
    static [bool] $ShowAllMovementTitles = (
        [ConfigurationStore]::GetRenderingItem(
            "AudioTrackTitleIncludeAllMovements").Value)

    # One or several characters which will be inserted between each movement's
    # title, if ShowAllMovementTitles is set to $true.
    static [string] $MovementTitleDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "AudioTrackTitleMovementDelimiter").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################
    
    # Id of the performed piece within the performance
    hidden [string] $PieceId

    # An SPath expression to the target section
    hidden [string] $SPath

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Related performance (included as a child element)
    [UmsMcePerformance] $Performance

    # Calculated: performed piece within the whole performance
    [UmsMcePiece] $Piece

    # Calculated: performed movements within the whole piece
    [UmsMceMovement[]] $Movements

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    # Throws:
    #   - [UEConstructorFailureException] on construction failure.
    UmsMceTrack([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        [EventLogger]::LogVerbose("Beginning instance construction.")

        try
        {
            # Validate the XML root element
            $this.ValidateXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "track")

            # Mandatory 'piece' attribute
            $this.PieceId = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "piece")

            # Mandatory 'section' attribute
            $this.SPath = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "section")

            # Mandatory 'performance' instance
            $this.Performance = [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "performance"),
                $this.SourcePathUri,
                $this.SourceFileUri)

            # Calculate the performed piece
            $this.CalculatePiece()

            # Update movements from the performed Piece
            $this.CalculateMovements()
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UEConstructorFailureException]::New()
        }
        
        [EventLogger]::LogVerbose("Finished instance construction.")
    }

    ###########################################################################
    # Calculators (View updaters)
    ###########################################################################

    # Sub-constructor for the 'Movements' calculated property
    # Requires the 'Piece' property to be initialized.
    # Throws:
    #   - [UESubConstructorFailureException] on failure.
    [void] CalculateMovements()
    {
        [EventLogger]::LogVerbose(
            "Beginning to calculate the value of the 'Movements' property.")
    
        [UmsMceMovement[]] $_results = $null

        try
        {
            $_results = [UmsMceSection]::GetMovementFromSPath(
                $this.Piece.Work.Sections,
                $this.SPath)
        }
        catch [UMENullSPathResultException]
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError("No movement could be linked to the track.")
            throw [UESubConstructorFailureException]::New(
                "CalculateMovements")
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New(
                "CalculateMovements")
        }

        [EventLogger]::LogVerbose("Got {0} movement instances.")

        # Each returned movement must be included in the performed piece.
        foreach ($_movement in $_results)
        {
            [EventLogger]::LogVerbose($(
                "Checking whether the movement with uid '{0}' " + `
                "is included in the performed piece.") `
                -f $_movement.Uid)

            if ($this.Piece.Movements -contains($_movement))
            {
                [EventLogger]::LogVerbose(
                    "The movement was found in the performed piece.")
            }
            else
            {
                [EventLogger]::LogError($(
                    "The movement with uid '{0}' from file '{1}' is not " + `
                    "included in the performed piece.") `
                    -f @($_movement.Uid, $_movement.SourceFileUri))
                throw [UESubConstructorFailureException]::New(
                    "CalculateMovements")
            }
        }

        # Store movements.
        $this.Movements = $_results
        [EventLogger]::LogVerbose(
            "Finished to calculate the value of the 'Movements' property.")
    } 

    # Sub-constructor for the 'Piece' calculated property
    # Requires the 'Performance' property to be initialized.
    # Throws:
    #   - [UEUnresolvableInternalReferenceException] if the track references
    #       an unresolvable piece of performance.
    #   - [UESubConstructorFailureException] on any other failure.
    [void] CalculatePiece()
    {
        [EventLogger]::LogVerbose(
            "Beginning to calculate the value of the 'Piece' property.")

        try
        {
            $this.Piece = [UmsMcePerformance]::GetPieceById(
                $this.Performance.Pieces,
                $this.PieceId)
        }
        catch [UEReferenceNotFoundException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UEUnresolvableInternalReferenceException]::New(
                "piece", $this.PieceId)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New(
                "CalculatePiece")
        }

        [EventLogger]::LogVerbose(
            "Finished to calculate the value of the 'Piece' property.")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns the string representation of the album track.
    [string] ToString()
    {
        # If no movement is present, we just return the basic track title
        if ($this.Movements.Count -eq 0)
            { return ([UmsBaeTrack] $this).ToString() }

        $_string = ""

        # Include track number, if enabled.
        if ([UmsBaeTrack]::ShowTrackNumber)
        {
            $_string += ([UmsBaeTrack]::TrackNumberFormat -f $this.Number)
            $_string += ([UmsAeEntity]::NonBreakingSpace)
        }

        [string[]] $_movementTitles = @()

        # If ShowAllMovementTitles is enabled, we need to render the title of
        # every movement.
        if ([UmsMceTrack]::ShowAllMovementTitles)
        {
            foreach ($_movement in $this.Movements)
                { $_movementTitles += $_movement.ToFullString() }
        }
        # Else, we only render a single movement title
        else
            { $_movementTitles += $this.Movements[0].ToFullString()  }

        # Merge movement titles
        $_string += $_movementTitles -join([UmsMceTrack]::MovementTitleDelimiter)

        return $_string
    }
}