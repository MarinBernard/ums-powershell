###############################################################################
#   Exception class ResourceCacheException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [ResourceCache] class.
#
###############################################################################

class ResourceCacheException : UmsException
{
    ResourceCacheException() : base() {}
}

###############################################################################
#   Exception class RCCacheDirectoryCreationFailureException
#==============================================================================
#
#   Thrown by the [ResourceCache] class after a write operation to the on-disk
#   cache has failed.
#
###############################################################################

class RCCacheDirectoryCreationFailureException : ResourceCacheException
{
    RCCacheDirectoryCreationFailureException(
        [System.IO.DirectoryInfo] $CacheDirectory
    ) : base()
    {
        $this.MainMessage =  ($(
            "Unable to create the resource cache directory " + `
            "at the following location: {0}") `
            -f $CacheDirectory.FullName)
    }
}

###############################################################################
#   Exception class RCCacheWriteFailureException
#==============================================================================
#
#   Thrown by the [ResourceCache] class after a write operation to the on-disk
#   cache has failed.
#
###############################################################################

class RCCacheWriteFailureException : ResourceCacheException
{
    RCCacheWriteFailureException(
        [System.Uri] $Uri,
        [System.IO.FileInfo] $CacheFile
    ) : base()
    {
        $this.MainMessage =  ($(
            "The resource at the following URI could not be saved " + `
            "as an on-disk cache file: {0}") `
            -f $Uri.AbsoluteUri)
        
        $this.SubMessages += ("Cache file name: {0}" -f $CacheFile.FullName)
    }
}

###############################################################################
#   Exception class RCGetCacheFileFailureException
#==============================================================================
#
#   Thrown when the [ResourceCache]::GetCacheFile method meets a fatal failure.
#
###############################################################################

class RCGetCacheFileFailureException : ResourceCacheException
{
    RCGetCacheFileFailureException(
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
#   Exception class RCHashGenerationFailureException
#==============================================================================
#
#   Thrown by the [ResourceCache] class when the md5 hash generation process
#   failed.
#
###############################################################################

class RCHashGenerationFailureException : ResourceCacheException
{
    RCHashGenerationFailureException(
        [string] $Algorithm,
        [string] $SourceData) : base()
    {
        $this.MainMessage = (
            "Unable to generate a {0} hash with algorithm from data: {1}" `
            -f $Algorithm,$SourceData)
    }
}

###############################################################################
#   Exception class RCFetchFailureException
#==============================================================================
#
#   Thrown when the ::GetResource() method has no resource to return.
#
###############################################################################

class RCFetchFailureException : ResourceCacheException
{
    RCFetchFailureException([System.Uri] $Uri) : base()
    {
        $this.MainMessage = ($(
            "The resource at the following location could not be fetched: " + `
            "{0}") `
            -f $Uri.AbsoluteUri)
    }
}