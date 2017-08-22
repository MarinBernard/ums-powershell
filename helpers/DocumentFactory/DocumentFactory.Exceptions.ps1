###############################################################################
#   Exception class DocumentFactoryException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [DocumentFactory] class.
#
###############################################################################

class DocumentFactoryException : UmsException
{
    DocumentFactoryException() : base() {}
}

###############################################################################
#   Exception class DFResourceRetrievalFailureException
#==============================================================================
#
#   Thrown by the [DocumentFactory] class when a remote document cannot be
#   be retrieved.
#
###############################################################################

class DFResourceRetrievalFailureException : DocumentFactoryException
{
    DFResourceRetrievalFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = (
            "The document at the following URI cannot not be retrieved: {0}" `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class DFNewDocumentFailureException
#==============================================================================
#
#   Thrown by the [DocumentFactory] class when a remote document cannot be
#   be retrieved.
#
###############################################################################

class DFNewDocumentFailureException : DocumentFactoryException
{
    DFNewDocumentFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = ($(
            "Unable to create a new UmsDocument instance from the document " + `
            "at the following location: {0}") `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class DFResourceConversionFailureException
#==============================================================================
#
#   Thrown by the [DocumentFactory] class if a fetched resource cannot be
#   converted to UTF-8.
#
###############################################################################

class DFResourceConversionFailureException : DocumentFactoryException
{
    DFResourceConversionFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = ($(
            "The resource at the following location " + `
            "cannot be converted to UTF-8: {0}") `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class DFCacheDocumentFailureException
#==============================================================================
#
#   Thrown by the [DocumentFactory]::GetDocument() class if it is unable to
#   add a new UmsDocument instance to the document cache.
#
###############################################################################

class DFCacheDocumentFailureException : DocumentFactoryException
{
    DFCacheDocumentFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = ($(
            "The document at the following location " + `
            "could not be added to the document cache: {0}") `
            -f $Uri.AbsoluteUri)
    }
}