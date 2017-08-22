###############################################################################
#   Abstract entity class UmsMaeEvent
#==============================================================================
#
#   This class describes an abstract UMS entity representing a musical event.
#   It inherits the 'event' abstract type from the base schema, from which it
#   differs in the type of the $Place property, which uses UmsMcePlace instead
#   of UmsBcePlace. 
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsMaeEvent : UmsBaeEvent
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
    
    # Place of the musical event
    # Overrides same-name property of type 'UmsBcePlace' in parent class.
    [UmsMcePlace] $Place

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsMaeEvent([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsMaeEvent")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Optional 'place' child element
        if ($XmlElement.place)
        {
            $this.Place = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "place"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }
    }

    ###########################################################################
    # Helpers
    ########################################################################### 
}