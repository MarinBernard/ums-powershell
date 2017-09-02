###############################################################################
#   Abstract entity class ForeignMetadataConverter
#==============================================================================
#
#   This class represents an abstract foreign metadata converter.
#
#   It must *NOT* be instantiated but rather be inherited by a concrete
#   foreign metadata converter.
#
###############################################################################

class ForeignMetadataConverter
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
    # Throws [AbstractClassInstantiationException] if this abstract class is
    # instantiated.
    ForeignMetadataConverter()
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "ForeignMetadataConverter")
        {
            throw [AbstractClassInstantiationException]::New(
                $this.getType().Name)
        }
    }

    ###########################################################################
    # Abstract methods
    ###########################################################################

    # Prototype for converting a UMS entity to foreign metadata. Return type is
    # a generic array of objects.
    # Parameters:
    #   - $Metadata is either a UMS entity or a deserialized UMS entity.
    #       We use the generic object type as static typing is impossible in
    #       such a context.
    # Throws [AbstractMethodCallException] if not overriden.
    [object[]] Convert([object] $Metadata)
    {
        throw [AbstractMethodCallException]::New(
            $this.getType().Name,
            "Convert")
    }
}