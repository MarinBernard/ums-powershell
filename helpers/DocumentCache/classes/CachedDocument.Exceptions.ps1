###############################################################################
#   Exception class CachedDocumentException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [CachedDocument] class.
#
###############################################################################

class CachedDocumentException : UmsException
{
    CachedDocumentException() : base() {}
}

###############################################################################
#   Exception class CDFileReadFailureException
#==============================================================================
#
#   Thrown by the [CachedDocument] constructor when a source file cannot
#   be read.
#
###############################################################################

class CDFileReadFailureException : CachedDocumentException
{
    CDFileReadFailureException(
        [string] $CacheFileName
    ) : base()
    {
        $this.MainMessage =  (
            "The cache file at the following location cannot be read: {0} " `
            -f $CacheFileName)
    }
}

###############################################################################
#   Exception class CDFileParseFailureException
#==============================================================================
#
#   Thrown by the [CachedDocument] constructor when an exception thrown by the
#   [UmsDocument] constructor is catched, which means the content of the file
#   cannot be parsed to a valid UMS document.
#
###############################################################################

class CDFileParseFailureException : CachedDocumentException
{
    CDFileParseFailureException(
        [string] $CacheFileName
    ) : base()
    {
        $this.MainMessage =  ($(
            "The cache file at the following location contains an invalid " + `
            "UMS document: {0} ") `
            -f $CacheFileName)
    }
}

###############################################################################
#   Exception class CDConstructionFailureException
#==============================================================================
#
#   Thrown by the [CachedDocument] constructor when the instance cannot be
#   constructed correctly.
#
###############################################################################

class CDConstructionFailureException : CachedDocumentException
{
    CDConstructionFailureException(
        [string] $CacheFileName
    ) : base()
    {
        $this.MainMessage =  ($(
            "Unable to create a CachedDocument instance from the cache " + `
            "file at the following location: {0} ") `
            -f $CacheFileName)
    }
}

###############################################################################
#   Exception class CDSourceUriUpdateFailureException
#==============================================================================
#
#   Thrown by the [CachedDocument]::UpdateSourceUri() method when the cached
#   UmsDocument instance refuses the SourceUri update.
#
###############################################################################

class CDSourceUriUpdateFailureException : CachedDocumentException
{
    CDSourceUriUpdateFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage =  (
            "Source URI update with the following URI has failed: {0}" `
            -f $Uri.AbsoluteUri)
    }
}