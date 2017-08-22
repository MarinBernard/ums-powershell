###############################################################################
#   Concrete class UmsCachedEntity
#==============================================================================
#
#   This class describes an instance of a UMS entity class when stored in the
#   entity cache. It includes a reference to the instance, and several
#   properties of the UMS entity which act as a primary key in the cache DB.
#
###############################################################################

class UmsCachedEntity
{
    ###########################################################################
    # Visible properties
    ###########################################################################

    # The XML namespace of the document element
    [string] $XmlNamespaceUri

    # The local name of the document element
    [string] $XmlElementName

    # The value of the 'uid' attribute.
    [string] $Uid

    # The optional URI to the source file if the entity was transcluded
    [string] $SourceUri

    # Whether transclusion source used a relative file name
    [bool] $RelativeSource

    # A reference to the entity instance
    [UmsAeEntity] $Instance

    ###########################################################################
    # Constructor
    ###########################################################################

    UmsCachedEntity(
        [string] $XmlNamespaceUri,
        [string] $XmlElementName,
        [string] $Uid,
        [string] $SourceUri,
        [string] $RelativeSource,
        [UmsAeEntity] $Instance)
    {
        $this.XmlNamespaceUri = $XmlNamespaceUri
        $this.XmlElementName = $XmlElementName
        $this.Uid = $Uid
        $this.SourceUri = $SourceUri
        $this.RelativeSource = $RelativeSource
        $this.Instance = $Instance
    }

    # Returns the instance of the cached entity
    [UmsAeEntity] GetInstance()
    {
        return $this.Instance
    }
}