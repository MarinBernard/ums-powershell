###############################################################################
#   Abstract entity class UmsBaeBinding
#==============================================================================
#
#   This class describes an abstract UMS entity representing a content binding.
#   It is inherited by all concrete binding classes from other namespaces.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeBinding : UmsAeEntity
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

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeBinding([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeBinding")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }
    }   

    ###########################################################################
    # Helpers
    ###########################################################################

}