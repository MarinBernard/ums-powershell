###############################################################################
#   Exception class DocumentCacheException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [DocumentCache] class.
#
###############################################################################

class DocumentCacheException : UmsException
{
    DocumentCacheException() : base() {}
}

###############################################################################
#   Exception class DCCacheDirectoryCreationFailureException
#==============================================================================
#
#   Thrown by the [DocumentCache] class after a write operation to the on-disk
#   cache has failed.
#
###############################################################################

class DCCacheDirectoryCreationFailureException : DocumentCacheException
{
    DCCacheDirectoryCreationFailureException(
        [System.IO.DirectoryInfo] $CacheDirectory
    ) : base()
    {
        $this.MainMessage =  ($(
            "Unable to create the document cache directory " + `
            "at the following location: {0}") `
            -f $CacheDirectory.FullName)
    }
}

###############################################################################
#   Exception class DCCacheWriteFailureException
#==============================================================================
#
#   Thrown by the [DocumentCache] class after a write operation to the on-disk
#   cache has failed.
#
###############################################################################

class DCCacheWriteFailureException : DocumentCacheException
{
    DCCacheWriteFailureException(
        [System.Uri] $Uri,
        [System.IO.FileInfo] $CacheFile
    ) : base()
    {
        $this.MainMessage =  ($(
            "The document at the following URI could not be saved " + `
            "as an on-disk cache file: {0}") `
            -f $Uri.AbsoluteUri)
        
        $this.SubMessages += ("Cache file name: {0}" -f $CacheFile.FullName)
    }
}

###############################################################################
#   Exception class DCGetCacheFileFailureException
#==============================================================================
#
#   Thrown when the [DocumentCache]::GetCacheFile method meets a fatal failure.
#
###############################################################################

class DCGetCacheFileFailureException : DocumentCacheException
{
    DCGetCacheFileFailureException(
        [System.Uri] $Uri
    ) : base()
    {
        $this.MainMessage =  ($(
            "Unable to build a reference to a cache file for the resource " + `
            "at the following location: {0}") `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class DCHashGenerationFailureException
#==============================================================================
#
#   Thrown by the [DocumentCache] class when the md5 hash generation process
#   failed.
#
###############################################################################

class DCHashGenerationFailureException : DocumentCacheException
{
    DCHashGenerationFailureException(
        [string] $Algorithm,
        [string] $SourceData) : base()
    {
        $this.MainMessage = (
            "Unable to generate a {0} hash with algorithm from data: {1}" `
            -f $Algorithm,$SourceData)
    }
}

###############################################################################
#   Exception class DCNewCachedDocumentFailureException
#==============================================================================
#
#   Thrown when an exception thrown by the [CachedDocument] constructor is
#   caught, which means that the document cannot be instantiated.
#
###############################################################################

class DCNewCachedDocumentFailureException : DocumentCacheException
{
    DCNewCachedDocumentFailureException([System.IO.FileInfo] $File) : base()
    {
        $this.MainMessage = ($(
            "Unable to create a cached document instance " + `
            "from the cache file at the following location: {0}") `
            -f $File.FullName)
    }
}

###############################################################################
#   Exception class DCCacheMissException
#==============================================================================
#
#   Thrown when the ::GetDocument() method has no document to return.
#
###############################################################################

class DCCacheMissException : DocumentCacheException
{
    DCCacheMissException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = ($(
            "The cache contains no cached version of the document " + `
            "at the following location: {0}") `
            -f $Uri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class DCSourceUriUpdateFailureException
#==============================================================================
#
#   Thrown by the [DocumentCache]::GetDocument() method when the call to the
#   UpdateSourceUri() method of the [UmsCachedDocument] instance fails.
#
###############################################################################

class DCSourceUriUpdateFailureException : DocumentCacheException
{
    DCSourceUriUpdateFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage =  (
            "Source URI update with the following URI has failed: {0}" `
            -f $Uri.AbsoluteUri)
    }
}