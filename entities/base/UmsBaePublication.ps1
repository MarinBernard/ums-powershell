###############################################################################
#   Abstract entity class UmsBaePublication
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic
#   publication. It deals with properties defined in the 'Publication' abstract
#   type from the base XML schema. It defines members which are common to all
#   types of UMS publication.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaePublication : UmsBaeProduct
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

    [UmsBceRelease[]]       $Releases

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaePublication([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaePublication")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Optional 'releases' element (collection of 'release' elements)
        if ($XmlElement.releases)
        {
            $this.BuildReleases(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "releases"))
        }
    }

    # Sub-constructor for the 'releases' element
    [void] BuildReleases([System.Xml.XmlElement] $ReleasesElement)
    {
        $this.GetOneOrManyXmlElement(
            $ReleasesElement,
            [UmsAeEntity]::NamespaceUri.Base,
            "release"
        ) | foreach {
                $this.Releases += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################
}