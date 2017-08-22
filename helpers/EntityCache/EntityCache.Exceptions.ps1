###############################################################################
#   Exception class EntityCacheException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [EntityCache] class.
#
###############################################################################

class EntityCacheException : UmsException
{
    EntityCacheException() : base() {}
}

###############################################################################
#   Exception class ECNoMatchException
#==============================================================================
#
#   Thrown by the [EntityCache]::GetEntity() method when no matching entity
#   was found in the cache.
#
###############################################################################

class ECNoMatchException : DocumentCacheException
{
    ECNoMatchException(
        [System.Uri] $SourceFileUri
    ) : base()
    {
        $this.MainMessage =  ($(
            "No suitable entity found in the entity cache " + `
            "for the following source file URI: {0}") `
            -f $SourceFileUri.AbsoluteUri)
    }
}

###############################################################################
#   Exception class ECBadCacheCardinalityException
#==============================================================================
#
#   Thrown by the [EntityCache]::GetEntity() method when a duplicate was found
#   in the entity cache. This shows a cache corruption.
#
###############################################################################

class ECBadCacheCardinalityException : DocumentCacheException
{
    ECBadCacheCardinalityException(
        [System.Uri] $SourceFileUri
    ) : base()
    {
        $this.MainMessage =  ($(
            "A duplicate entity instance was found in the entity cache " + `
            "for the following source document URI: {0}") `
            -f $SourceFileUri.AbsoluteUri)
    }
}