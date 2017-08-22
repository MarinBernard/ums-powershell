###############################################################################
#   Static class EntityCache
#==============================================================================
#
#   This class provides in-memory caching for UMS entity instances.
#
###############################################################################

class EntityCache
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Entity cache
    static [UmsCachedEntity[]] $CachedEntities

    # Cache statistics
    static [hashtable] $Statistics

    ###########################################################################
    # Static constructor
    ###########################################################################

    static EntityCache()
    {
        # Initialize statistics
        [EntityCache]::Reset()
    }

    ###########################################################################
    # API
    ###########################################################################

    # Adds an entity instance to the cache
    static [void] AddEntity([UmsAeEntity] $Entity)
    {
        # Check whether the entity is already cached
        if ([EntityCache]::HasEntity($Entity))
        {
            [EntityCache]::Statistics.CacheIgnored += 1
            [EventLogger]::LogVerbose(
                "The entity is already present in the cache.")
        }
        else
        {
            # Cache the entity
            [EntityCache]::Statistics.CacheAdditions += 1
            [EntityCache]::CachedEntities += (
                New-Object -Type UmsCachedEntity -ArgumentList @(
                    $Entity.XmlNamespaceUri,
                    $Entity.XmlElementName,
                    $Entity.Uid,
                    $Entity.SourceFileUri,
                    $Entity.RelativeSource,
                    $Entity))
        }
    }

    # Returns the content of the entity cache
    static [UmsCachedEntity[]] Dump()
    {
        return [EntityCache]::CachedEntities
    }
    
    # Force the removal of all cached entities but keeps statistics
    # This method does not throw any custom exception.
    static [void] Flush()
    {
        [EntityCache]::CachedEntities = @()
        [EventLogger]::LogVerbose("Entity cache was flushed.")
    }

    # Returns the instance of a cached entity.
    # Throws:
    #   - [ECNoMatchException] if there is no matching entity in the cache.
    #   - [ECBadCacheCardinalityException] if the cache contains several
    #       matching cached entities, which is a sign of corruption.
    static [UmsAeEntity] GetEntity(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourceFileUri)
    {
        # Retrieve a matching cached entity instance
        [UmsCachedEntity[]] $_cachedEntity = (
            [EntityCache]::CachedEntities | Where-Object {
                ($_.XmlNamespaceUri -eq $XmlElement.NamespaceUri) -and
                ($_.XmlElementName -eq $XmlElement.LocalName)     -and
                ($_.SourceUri -eq $SourceFileUri)                 -and
                ($_.Uid -eq $XmlElement.Uid)})

        # Validate cardinality. We expect exactly one result.
        if ($_cachedEntity.Count -eq 0)
        {
            [EntityCache]::Statistics.CacheMisses += 1
            throw [ECNoMatchException]::New($SourceFileUri)
            
        }
        if ($_cachedEntity.Count -ne 1)
        {
            throw [ECBadCacheCardinalityException]::New($SourceFileUri)  
        }

        [EntityCache]::Statistics.CacheHits += 1
        return $_cachedEntity[0].GetInstance()
    }

    # Returns a PSCustomObject from the ::Statistics array.
    # This method does not throw any custom exception.
    static [PSCustomObject[]] GetStatistics()
    {
        return New-Object `
            -Type "PSCustomObject" `
            -Property ([EntityCache]::Statistics)
    }

    # Searches the cache for a matching entity. Returns $true if a match is
    # found, $false otherwise.
    static [bool] HasEntity(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourceFileUri)
    {
        [EntityCache]::Statistics.CacheQueries += 1

        # Return false if the cache is empty
        if ([EntityCache]::CachedEntities.Count -eq 0){ return $false }

        return (([EntityCache]::CachedEntities | Where-Object {
            ($_.XmlNamespaceUri -eq $XmlElement.NamespaceUri) -and
            ($_.XmlElementName -eq $XmlElement.LocalName)     -and
            ($_.SourceUri -eq $SourceFileUri)                 -and
            ($_.Uid -eq $XmlElement.Uid) }).Count -eq 1)
    }

    # Searches the cache for a specific entity. Returns $true if a match is
    # found, $false otherwise.
    static [bool] HasEntity([UmsAeEntity] $Entity)
    {
        [EntityCache]::Statistics.CacheQueries += 1

        # Return false if the cache is empty
        if ([EntityCache]::CachedEntities.Count -eq 0){ return $false }

        return ([EntityCache]::CachedEntities |
            Where-Object { $_.Instance -eq $Entity })
    }

    # Removes any cached entity from the cache and resets statistics.
    # This method does not throw any custom exception.
    static [void] Reset()
    {
        [EventLogger]::LogVerbose("Resetting entity cache.")
        [EntityCache]::Flush()
        [EntityCache]::Statistics = (
            [ordered] @{
                CacheAdditions = 0;
                CacheIgnored = 0;
                CacheHits = 0;
                CacheMisses = 0;
                CacheQueries = 0;
        })
    }
}