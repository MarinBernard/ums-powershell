###############################################################################
#   Abstract entity class UmsBaeStandard
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic
#   standard. It deals with properties defined in the 'Standard' abstract type
#   from the XML schema.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeStandard : UmsBaeItem
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [UmsBaeStandard_Status]    $Status
    [UmsBaeStandard_Segment[]] $Segments

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeStandard([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeStandard")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Mandatory 'status' element
        $this.Status = (
            $this.GetOneXmlElementValue(
                $XmlElement,
                [UmsAeEntity]::NamespaceUri.Base,
                "status"))

        # Optional 'segments' element (collection of 'segment' elements)
        if ($XmlElement.segments)
        {
            $this.BuildSegments(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "segments"))     
        }
    }

    # Sub-constructor for the 'segments' element
    [void] BuildSegments([System.Xml.XmlElement] $SegmentsElement)
    {
        $this.GetOneOrManyXmlElement(
            $SegmentsElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "segment"
        ) | foreach { $this.Segments += [UmsBaeStandard_Segment]::New($_) }

        # Sort segments by order
        $this.Segments = $this.Segments | Sort-Object -Property Order
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Build the full ID of a standard ID from a collection of ID segments.
    [string] ConstructId([UmsBaeStandard_IdSegment[]] $IdSegments)
    {
        [string] $_string = ""

        [EventLogger]::LogVerbose(
            "Beginning to construct an ID for standard: {0}" `
            -f $this.ToString())

        foreach ($_segment in $this.Segments)
        {            
            # Try to gather an ID segment of the same level
            $_idSegment = $IdSegments |
                Where-Object { $_.Level -eq $_segment.Order }

            if ($_idSegment)
            {
                [EventLogger]::LogVerbose(
                    "Matching segment found with value: {0}" `
                    -f $_idSegment.Value)
                
                $_string += $_segment.GetPrefix()
                $_string += $_idSegment.Value
            }

            # If no match was found and the segment was mandatory
            elseif ($_segment.Mandatory)
            {
                [EventLogger]::LogVerbose(
                    "No matching segment found but the segment is mandatory.")
                
                throw [UEMandatoryStandardIdSegmentNotFoundException]::New(
                    $_segment
                )
            }

            # If no match was found and the segment was optional
            else
            {
                [EventLogger]::LogVerbose(
                    "No matching segment found but the segment is optional.")
                continue;
            }
        }

        return $_string
    }

    # Renders the standard name to string
    [string] ToString()
    {
        # If a short label exists, use it first.
        if ($this.Label.ShortLabel)
            { return $this.Label.ShortLabel }
        
        # Else, return the default string representation for string items
        else
            { return ([UmsBaeItem] $this).ToString() }
    }
}

###############################################################################
#   Local enum UmsBaeStandard_Status
#==============================================================================
#
#   Describes the status of a standard.
#
###############################################################################

Enum UmsBaeStandard_Status
{
    Current
    Deprecated
}