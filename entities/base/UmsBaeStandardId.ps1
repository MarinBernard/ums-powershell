###############################################################################
#   Abstract entity class UmsBaeStandardId
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic
#   standardId, which is a liaison between a standard, and a standard record.
#   Such associations are very common in UMS metadata, and this class provides
#   common properties and methods to deal with it. It is used a base for
#   the UmsBceStandardId concrete class, which describes generic standard IDs,
#   but also for the UmcMceCatalogId concrete class, which describes a record
#   in a music catalog.
#
#   This abstract type has no equivalent in the XML schema, as it does not
#   include any equivalent to abstract classes in OOP.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeStandardId : UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # A collection of segments which must be grouped together to form the final
    # ID. This property is hidden because we expose the final, reconstructed
    # ID as a string with the 'Id' visible property.
    hidden [UmsBaeStandard_IdSegment[]] $Segments

    ###########################################################################
    # Visible properties
    ###########################################################################

    # A reference to the linked standard. Derivated classes may include
    # additional references the same standard with more precise names.
    [UmsBaeStandard] $Standard

    # Reconstructed ID.
    [string] $Id

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBaeStandardId([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeStandardId")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }
        
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
        ) | foreach { $this.Segments += [UmsBaeStandard_IdSegment]::New($_) }
    }

    ###########################################################################
    # Late registration
    ###########################################################################    

    # Registers the UmsBaeStandard instance after this instance was
    # constructed. This method must be called by the constructors of all
    # derivated classes, which are the only ones to know the name of the 
    # XML element describing the standard.
    [void] RegisterStandard([UmsBaeStandard] $Standard)
    {
        $this.Standard = $Standard
        $this.Id = $this.Standard.ConstructId($this.Segments)
    }

    ###########################################################################
    # Helpers
    ###########################################################################
    
    # String representation
    [string] ToString()
    {
        return $this.Standard.ToString()
    }
}