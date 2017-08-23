###############################################################################
#   Abstract entity class ForeignMetadataUpdater
#==============================================================================
#
#   This class represents an abstract foreign metadata updated.
#
#   It must *NOT* be instantiated but rather be inherited by a concrete
#   foreign metadata converter.
#
###############################################################################

class ForeignMetadataUpdater
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
    ForeignMetadataUpdater()
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "ForeignMetadataUpdater")
        {
            throw [AbstractClassInstantiationException]::New(
                $this.getType().Name)
        }
    }

    ###########################################################################
    # Abstract methods
    ###########################################################################

    # Prototype for getting a reference to the file containing the external
    # version of foreign metadata.
    # Throws [AbstractMethodCallException] if not overriden.
    [System.IO.FileInfo] GetExternalVersionFile([object] $Target)
    {
        throw [AbstractMethodCallException]::New(
            $this.getType().Name,
            "UpdateExternalVersion")
    }

    # Prototype for updating the embedded version of foreign metadata.
    # Throws [AbstractMethodCallException] if not overriden.
    [void] UpdateEmbeddedVersion([object] $Target, [object] $Metadata)
    {
        throw [AbstractMethodCallException]::New(
            $this.getType().Name,
            "UpdateExternalVersion")
    }

    # Prototype for updating the external version of foreign metadata.
    # Throws [AbstractMethodCallException] if not overriden.
    [void] UpdateExternalVersion([object] $Target, [object] $Metadata)
    {
        throw [AbstractMethodCallException]::New(
            $this.getType().Name,
            "UpdateExternalVersion")
    }
}