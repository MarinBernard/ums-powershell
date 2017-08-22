###############################################################################
#   Concrete entity class UmsMcePiece
#==============================================================================
#
#   This class describes a piece of the programme of a music performance, built
#   from a 'piece' XML element from the music namespace. The 'piece' entity
#   links a music composition to its performed sections.
#
###############################################################################

class UmsMcePiece : UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    static [string] $PartialPieceSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformancePartialPieceSuffix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # The SPath expression which will be used to filter the original, full list
    # of sections in the performed work, and build a list of performed sections
    # stored in the Sections property.
    hidden [string] $SPath

    # The parent performance of the piece. This property is updated after the
    # instance is constructed, and is used to build the string representation
    # of the piece, which includes performance data.
    # Tags:
    #   - DependencyLoopPrevention
    hidden [object] $ParentPerformance

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Id of the performed piece within the whole performance.
    [string] $Id

    # Whether the work is fully or partially performed.
    [bool] $Partial    

    # A reference to the performed work.
    [UmsMceWork] $Work

    # Collection of performed movements of the work. The collection is built
    # from the SPath expression stored in the SPath property.
    [UmsMceMovement[]] $Movements

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMcePiece([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        [EventLogger]::LogVerbose("Beginning instance construction.")

        try
        {
            # Validate the XML root element
            $this.ValidateXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "piece")

            # Mandatory 'id' attribute
            $this.Id = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "id")

            # Mandatory 'section' attribute
            $this.SPath = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "section")

            # Mandatory 'work' element
            $this.Work = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "work"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))

            # Update the $Partial property
            if ($this.SPath -ne "*")  { $this.Partial = $true }

            # Calculate the 'Movements' property
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
    # Requires the 'Work' property to be initialized.
    [void] CalculateMovements()
    {
        [EventLogger]::LogVerbose(
            "Beginning to calculate the value of the 'Movements' property.")

        try
        {
            $this.Movements = [UmsMceSection]::GetMovementFromSPath(
                $this.Work.Sections,
                $this.SPath)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New(
                "CalculateMovements")
        }

        [EventLogger]::LogVerbose(
            "Finished to calculate the value of the 'Movements' property.")
    }

    ###########################################################################
    # Late updaters
    ###########################################################################

    # Updates the parent performance after the instance was constructed.
    # Tags:
    #   - DependencyLoopPrevention
    [void] UpdateParentPerformance([object] $ParentPerformance)
    {
        $this.ParentPerformance  = $ParentPerformance
    }

    ###########################################################################
    # String helpers
    ###########################################################################

    # Returns the title of the piece without performance data.
    # Throws: nothing.
    [string] GetPieceTitle()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()

        # Add work title to the buffer
        $_sb.Append($this.Work.ToString())

        # Optional partial suffix
        if ($this.Partial)
        {
            $_sb.Append([UmsAeEntity]::NonBreakingSpace)
            $_sb.Append([UmsMcePiece]::PartialPieceSuffix)
        }

        return $_sb.ToString()
    }

    # Returns the title of the piece including performance data.
    # Throws: nothing.
    [string] GetPerformedPieceTitle()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()

        # Add piece title to the buffer
        $_sb.Append($this.GetPieceTitle())

        # Add performance title suffix
        $_sb.Append([UmsAeEntity]::NonBreakingSpace)
        $_sb.Append($this.ParentPerformance.RenderPerformanceTitleSuffix())

        return $_sb.ToString()
    }    

    # Render the piece to string. Alias for GetPerformedPieceTitle().
    # Throws: nothing.
    [string] ToString()
    {
        return $this.GetPerformedPieceTitle()
    }
}