###############################################################################
#   Concrete entity class UmsMceSection
#==============================================================================
#
#   This class describes a music section entity, built from an 'section' XML
#   element from the music namespace. A section entity describes a section from
#   a musical work, which is a grouping of one or several movements.
#
###############################################################################

class UmsMceSection : UmsBaeProduct
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether the numbering of the section will be shown when it is rendered
    # as a string.
    static [bool] $ShowSectionNumber = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicSectionNumberShow").Value)

    # One or several characters which will be inserted between the section
    # number and the section title.
    static [string] $SectionNumberDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicSectionNumberDelimiter").Value)

    # One or several characters which will be inserted between each section
    # level when the section hierarchy is rendered as a string.
    static [string] $SectionLevelDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicSectionLevelDelimiter").Value)

    # Whether the title of the section will be shown when rendered as a string.
    static [bool] $ShowSectionTitle = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicSectionTitleShow").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Parent section of the section
    hidden [UmsMceSection] $ParentSection

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Identifier of the section. The unicity of this ID may only be assumed
    # within the same level of the section tree.
    [string] $Id

    # Absolute unique identifier of the section. This ID includes IDs of the
    # parent sections.
    [string] $AbsoluteId    

    # Numbering of the section
    [string] $Numbering

    # Absolute numbering of the section, including parent sections' numbering.
    [string] $AbsoluteNumbering 

    # Subsections of the section
    [UmsMceSection[]] $Sections

    # Movements of the section
    [UmsMceMovement[]] $Movements

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    # Throws:
    #   - [UEConstructorFailureException] on construction failure.
    UmsMceSection([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        [EventLogger]::LogVerbose("Beginning instance construction.")

        try
        {
            # Validate the XML root element
            $this.ValidateXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "section")

            # Mandatory attributes
            $this.Id = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "id")        
            $this.Numbering = $this.GetMandatoryXmlAttributeValue(
                $XmlElement, "numbering")

            # Default absolute ID is the ID of the section. The absolute ID
            # may be updated later, when the UpdateParentSection() is invoked.
            # This property must be set before subsections are instantiated.
            $this.AbsoluteId = $this.Id
            $this.AbsoluteNumbering = $this.Numbering
            
            # Optional 'sections' element (collection of 'section' elements)
            if ($XmlElement.sections)
            {
                $this.BuildSections(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "sections"))
            }

            # Optional 'movements' element (collection of 'movement' elements)
            elseif ($XmlElement.movements)
            {
                $this.BuildMovements(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "movements"))
            }
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UEConstructorFailureException]::New()
        }
        
        [EventLogger]::LogVerbose("Finished instance construction.")
    }

    ###########################################################################
    # Sub-constructors
    ###########################################################################

    # Sub-constructor for the 'sections' element
    # Throws:
    #   - [UESubConstructorFailureException] on construction failure.
    [void] BuildSections([System.Xml.XmlElement] $SectionsElement)
    {
        [EventLogger]::LogVerbose(
            "Beginning to build the 'Sections' collection.")

        try
        {
            $this.GetOneOrManyXmlElement(
                $SectionsElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "section"
            ) | foreach {
                $_section = [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri)
                $_section.UpdateParentSection($this)
                $this.Sections += $_section
            }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New(
                "BuildSections")
        }

        [EventLogger]::LogVerbose(
            "Finished to build the 'Sections' collection.")
    }

    # Sub-constructor for the 'movements' element
    #   - [UESubConstructorFailureException] on construction failure.
    [void] BuildMovements([System.Xml.XmlElement] $MovementsElement)
    {
        [EventLogger]::LogVerbose(
            "Beginning to build the 'Movements' collection.")

        try
        {
            $this.GetOneOrManyXmlElement(
                $MovementsElement,
                [UmsAeEntity]::NamespaceUri.Music,
                "movement"
            ) | foreach {
                $_movement = [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri)
                $_movement.UpdateParentSection($this)
                $this.Movements += $_movement
            }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UESubConstructorFailureException]::New(
                "BuildMovements")
        }

        [EventLogger]::LogVerbose(
            "Finished to build the 'Movements' collection.")
    }

    ###########################################################################
    # Late updaters
    ###########################################################################

    # Updates the parent section after the instance was constructed.
    [void] UpdateParentSection([UmsMceSection] $ParentSection)
    {
        $this.ParentSection  = $ParentSection

        $this.AbsoluteId = $(
            $this.ParentSection.AbsoluteId + `
            "/" + `
            $this.Id)

        $this.AbsoluteNumbering = $(
            $this.ParentSection.AbsoluteNumbering + `
            ([UmsMceSection]::SectionNumberDelimiter) + `
            $this.Numbering)
    }

    ###########################################################################
    # Static SPath helpers
    ###########################################################################    

    # Returns a collection of movements (UmsMceMovement instances) from a
    # SPath expression.
    # Parameters:
    #   - $Sections if a collection of sections (UmsMceSection instances)
    #   - SPath is a SPath expression.
    # Throws:
    #   - [UMENullSPathResultException] when the SPath expression returns
    #       nothing.
    static [UmsMceMovement[]] GetMovementFromSPath(
        [UmsMceSection[]] $Sections,
        [string] $SPath)
    {
        # Initialize the returned collection
        [UmsMceMovement[]] $_results = @()

        # Try to get the matching sections
        try
        {
            [UmsMceSection[]] $_sections = (
                [UmsMceSection]::GetSectionFromSPath(
                    $Sections, $SPath))
        }
        # If there is no matching section, we throw an exception as null
        # results are illegal
        catch [UMENullSPathResultException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UMENullSPathResultException]::New($SPath)
        }

        # Process all matching sections
        foreach ($_section in $_sections)
        {
            # If the section has subsections, we make a recursive call with
            # the global selector to get all movement instances from its
            # subsections.
            if ($_section.Sections.Count -gt 0)
            {
                $_results += (
                    [UmsMceSection]::GetMovementFromSPath(
                        $_section.Sections,
                        "*"))
            }
            # Else, return the movements of the section.
            else
            {
                $_results += $_section.Movements
            }
        }

         # Null results are not legal
         if ($_results.Count -eq 0)
         {
             throw [UMENullSPathResultException]::New($SPath)
         }
         
         return $_results
    }

    # Returns all sections matching a SPath expression. This method always
    #  returns the deepest matching section.
    # Parameters:
    #   - $Sections if a collection of sections (UmsMceSection instances)
    #   - SPath is a SPath expression.
    # Throws:
    #   - [UMENullSPathResultException] when the SPath expression returns
    #       nothing.
    static [UmsMceSection[]] GetSectionFromSPath(
        [UmsMceSection[]] $Sections,
        [string] $SPath)
    {
        [UmsMceSection[]] $_results = $null

        # Split the SPath expression into segments.
        $_segments = $SPath.Split("/")
        $_currentSegment = $_segments[0]
        $_remainingSegments = $_segments[1..$_segments.Length]

        [EventLogger]::LogVerbose(
            "Current SPath segment is: {0}" -f $_currentSegment)
        [EventLogger]::LogVerbose(
            "Number of remaining segments: {0}" -f $_remainingSegments.Count)

        foreach ($_section in $Sections)
        {
            [EventLogger]::LogVerbose(
                "Processing section with ID: {0}" -f $_section.Id)

            # If the current segment is the global selector (*), or the current
            # segment matches the ID of the current section, we must process
            # section.
            if (
                ($_currentSegment -eq "*") -or
                ($_section.Id -eq $_currentSegment))
            {
                # If there is no more remaining segments, subsections are
                # included in the SPath domain. We return this section as
                # a result.
                if ($_remainingSegments.Count -eq 0)
                {
                    $_results += $_section
                }
                # If there are still remaining segments, the filtering must be
                # continued in subsections. We call ourselves recursively.
                else
                {
                    $_results += ([UmsMceSection]::GetSectionFromSPath(
                        $_section.Sections,
                        ($_remainingSegments -join("/"))))
                }
            }
        }

        # Null results are not legal
        if ($_results.Count -eq 0)
        {
            [EventLogger]::LogError("SPath expression yielded no result.")
            throw [UMENullSPathResultException]::New($SPath)
        }
        
        return $_results
    }

    ###########################################################################
    # String helpers
    ###########################################################################

    # Renders the section as a string including data inherited from parent
    # sections.
    [string] ToFullString()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()

        # Include parent sections, if any
        if ($this.ParentSection)
        {
            $_sb.Append($this.ParentSection.ToString())

            # Delimiter is shown only if section titles are enabled
            if ([UmsMceSection]::ShowSectionTitle)
            {
                $_sb.Append([UmsMceSection]::SectionLevelDelimiter)
            }
        }

        $_sb.Append($this.ToString())

        return $_sb.ToString()
    }

    # Renders the section as a string.
    [string] ToString()
    {
        [System.Text.StringBuilder] $_sb = [System.Text.StringBuilder]::New()
        $_addSpace = $false

        # Add section numbering, if enabled
        if ([UmsMceSection]::ShowSectionNumber)
        {
            # Include numbering of the current section.
            $_sb.Append($this.Numbering)
            $_sb.Append([UmsMceSection]::SectionNumberDelimiter)
            $_addSpace = $true
        }

        # Add section title, if enabled
        $_title = ([UmsBaeProduct] $this).ToString()
        if (([UmsMceSection]::ShowSectionTitle) -and ($_title))
        {
            if ($_addSpace) { $_sb.Append([UmsAeEntity]::NonBreakingSpace) }
            $_sb.Append($_title)
            $_addSpace = $true        
        }

        return $_sb.ToString()
    }
}