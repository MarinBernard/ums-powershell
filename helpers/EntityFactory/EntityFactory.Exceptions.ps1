###############################################################################
#   Exception class EntityFactoryException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [EntityFactory] class.
#
###############################################################################

class EntityFactoryException : UmsException
{
    EntityFactoryException() : base() {}
}

###############################################################################
#   Exception class EFClassLookupFailureException
#==============================================================================
#
#   Thrown by the [EntityFactory]::NewEntity() method when no entity class
#   was found which match the supplied XML element.
#
###############################################################################

class EFClassLookupFailureException : EntityFactoryException
{
    EFClassLookupFailureException([System.Xml.XmlElement] $XmlElement) : base()
    {
        $this.MainMessage =  ($(
            "No suitable entity class was found which match the supplied " + `
            "XML element '{0}', from namespace '{1}'") `
            -f $XmlElement.LocalName,$XmlElement.NamespaceURI)
    }
}

###############################################################################
#   Exception class EFNullXmlElementException
#==============================================================================
#
#   Thrown by the [EntityFactory]::GetEntity() method when the supplied XML
#   element is null.
#
###############################################################################

class EFNullXmlElementException : EntityFactoryException
{
    EFNullXmlElementException(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourcePathUri,
        [string] $SourceFileUri)
        : base()
    {
        $this.MainMessage =  ($(
            "Cannot return an entity instance from a null Xml element. " + `
            "Source file URI is: {0}") `
            -f $SourceFileUri)
    }
}

###############################################################################
#   Exception class EFCacheFailureException
#==============================================================================
#
#   Thrown by the [EntityFactory] class when the [EntityCache] class throws
#   a fatal failure exception.
#
###############################################################################

class EFCacheFailureException : EntityFactoryException
{
    EFCacheFailureException(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourcePathUri,
        [string] $SourceFileUri)
        : base()
    {
        $this.MainMessage =  ("Entity cache fatal failure.")
    }
}

###############################################################################
#   Exception class EFDocumentFactoryFailureException
#==============================================================================
#
#   Thrown by the [EntityFactory] class when the [DocumentFactory] class throws
#   a fatal failure exception.
#
###############################################################################

class EFDocumentFactoryFailureException : EntityFactoryException
{
    EFDocumentFactoryFailureException()
        : base()
    {
        $this.MainMessage =  ("Document factory fatal failure.")
    }
}

###############################################################################
#   Exception class EFUnresolvableReferenceException
#==============================================================================
#
#   Thrown by the [EntityFactory]::GetReferenceTargetDocument() method when
#   a UMS reference could not be resolved.
#
###############################################################################

class EFUnresolvableReferenceException : EntityFactoryException
{
    EFUnresolvableReferenceException(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourcePathUri)
        : base()
    {
        $this.MainMessage =  (
            $("Unable to resolve a UMS reference involving XML element " + `
            "'{0}', from namespace '{1}', with source path URI '{2}'.") `
            -f $XmlElement.LocalName,$XmlElement.NamespaceURI,$SourcePathUri)
    }
}

###############################################################################
#   Exception class EFProcessDocumentFailureException
#==============================================================================
#
#   Thrown by the [EntityFactory]::ProcessDocument() method when the supplied
#   document cannot be parsed.
#
###############################################################################

class EFProcessDocumentFailureException : EntityFactoryException
{
    EFProcessDocumentFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage =  (
            $("An error occurred during the parsing of the UMS document " + `
            "with the following URI: {0}") `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class EFUnsupportedXmlElementException
#==============================================================================
#
#   Thrown by the [EntityFactory]::GetEntity() method when the supplied
#   XML element cannot be resolved to an entity class.
#
###############################################################################

class EFUnsupportedXmlElementException : EntityFactoryException
{
    EFUnsupportedXmlElementException() : base()
    {
        $this.MainMessage =  ("The supplied XML element is not supported.")
    }
}

###############################################################################
#   Exception class EFEntityInstantiationFailureException
#==============================================================================
#
#   Thrown  when a constructor on entity construction failure.
#
###############################################################################

class EFEntityInstantiationFailureException : EntityFactoryException
{
    EFEntityInstantiationFailureException() : base()
    {
        $this.MainMessage =  ("At least one entity instantiation has failed.")
    }
}