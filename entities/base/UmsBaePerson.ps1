###############################################################################
#   Abstract entity class UmsBaePerson
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic person.
#   It deals with properties defined in the 'Person' abstract type from the XML
#   schema.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaePerson : UmsBaeResource
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Collection of all name variants
    hidden [UmsBceNameVariant[]] $NameVariants

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Elected name variant
    [UmsBceNameVariant] $Name

    # Birth event
    [UmsBceBirth] $Birth

    # Death event
    [UmsBceDeath] $Death

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaePerson([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeVariant")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Build mandatory name variants
        $this.BuildNameVariants(
            $this.GetOneXmlElement(
                $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "nameVariants"))
        
        # Build birth event instance
        if ($XmlElement.birth)
        {
            $this.Birth = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "birth"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }
        
        # Build death event instance
        if ($XmlElement.death)
        {
            $this.Death = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "death"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }
    }

    # Builds instances of all name variants and elects the best one.
    [void] BuildNameVariants([System.Xml.XmlElement] $NameVariantsElement)
    {
        $this.GetOneOrManyXmlElement(
            $NameVariantsElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "nameVariant") |
        foreach {
                $this.NameVariants += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }

        # Get the best name variant
        $this.Name = [UmsBaeVariant]::GetBestVariant($this.NameVariants)
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # String representation
    [string] ToString()
    {
        return $this.Name
    }

}