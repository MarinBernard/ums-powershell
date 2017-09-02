###############################################################################
#   Static class ResourceCache
#==============================================================================
#
#   This class implements a caching mechanism for generic resources.
#
###############################################################################

class ResourceCache
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # The lifetime of all cached resources
    static $ResourceLifetime = (
        [ConfigurationStore]::GetSystemItem(
            "ResourceCacheLifeTime").Value)

    # References to all cached resources, created from the content of the cache
    # folder.
    static [System.IO.FileInfo[]] $CachedResources = @()

    # The folder used for on-disk caching
    static [System.IO.DirectoryInfo] $CacheFolder

    # Statistics
    static [hashtable] $Statistics = @{}

    ###########################################################################
    # Visible properties
    ###########################################################################

    ###########################################################################
    # Cache initializer
    ###########################################################################

    # Initializes instance statistics and creates the cache directory.
    # Throws:
    #   - [RCCacheDirectoryCreationFailureException] on cache directory
    #       creation failure.
    static Initialize([System.IO.DirectoryInfo] $CacheFolder)
    {   
        # Create the on-disk cache folder, if needed
        if (-not $CacheFolder.Exists)
        {
            try
            {
                $CacheFolder.Create()
            }
            catch [System.IO.IOException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [RCCacheDirectoryCreationFailureException]::New(
                    $CacheFolder)
            }
        }

        # Store a new instance of the cache folder
        [ResourceCache]::CacheFolder = (
            [System.IO.DirectoryInfo] $CacheFolder.FullName)

        # Initialize document cache and cache statistics
        [ResourceCache]::Reset()

        # Populate the cache
        [ResourceCache]::Restore()
    }

    ###########################################################################
    # API
    ###########################################################################

    # Adds a resource to the cache with an associated URI.
    # Throws:
    #   - [RCFetchFailureException] if the resource cannot be fetched.
    #   - [RCCacheWriteFailureException] if the resource cannot be added to
    #       the on-disk cache.
    static [void] AddResource([System.Uri] $Uri)
    {
        [EventLogger]::LogVerbose(
            ("Beginning to fetch resource at URI: {0}" -f $Uri.AbsoluteUri))

        # Build the reference to the cache file
        [System.IO.FileInfo] $_cacheFile = [ResourceCache]::GetCacheFile($Uri)

        [EventLogger]::LogVerbose(
            ("Cache file full name: {0}" -f $_cacheFile.FullName))

        # Try to fetch the resource
        try
        {
            $_webClient = [System.Net.WebClient]::New()
            $_webClient.DownloadFile($Uri.AbsoluteUri, $_cacheFile)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            
            # Remove cache file on fetch failure
            Remove-Item -Path $_cacheFile.FullName

            throw [RCFetchFailureException]::New($Uri)
        }

        [ResourceCache]::Statistics.AddedDocuments += 1
        # Store an updated instance of the cache file.
        [ResourceCache]::CachedResources += [ResourceCache]::GetCacheFile($Uri)
        [EventLogger]::LogVerbose("Resource was fetched successfully.")
    }

    # Returns the whole CachedResources collection after a TTL update.
    # This method does not throw any custom exception.
    static [System.IO.FileInfo[]] Dump()
    {
        [ResourceCache]::RemoveExpiredCachedResources()
        return [ResourceCache]::CachedResources
    }

    # Force the removal of all expired resources but keeps statistics
    # This method does not throw any custom exception.
    static [void] Flush()
    {
        foreach ($_cachedResource in [ResourceCache]::CachedResources)
        {
            [ResourceCache]::RemoveCachedResource($_cachedResource)
        }
    }

    # Returns a reference to a cache file from a resource URI.
    # Throws:
    #   - [RCGetCacheFileFailureException] on fatal failure.
    static [System.IO.FileInfo] GetCacheFile([System.Uri] $Uri)
    {
        # Try to build the name of the cache file
        [string] $_hash = $null
        try
        {
            $_hash = [ResourceCache]::GetUriHash($Uri)
        }
        catch [RCHashGenerationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [RCGetCacheFileFailureException]::New($Uri)
        }

        [EventLogger]::LogDebug(("Computed hash is: {0}" -f $_hash))

        # Try to build the full path to the cache file
        [string] $_path = $null
        try
        {
            $_path = Join-Path `
                -Path ([ResourceCache]::CacheFolder) `
                -ChildPath $_hash `
                -ErrorAction Stop
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [RCGetCacheFileFailureException]::New($Uri)
        }

        return [System.IO.FileInfo] $_path
    }

    # Returns a cached resource from its URI. If the cached resource is not
    # present in the cache, it is fetched and cached, then the method is called
    # again recursively.
    # Throws:
    #   - [DCCacheMissException] on cache miss.
    static [System.IO.FileInfo] GetResource([System.Uri] $Uri)
    {
        # Returned reference
        [System.IO.FileInfo] $_result = $null

        # Remove expired resources from the cache
        [ResourceCache]::RemoveExpiredCachedResources()

        $_hash  = [ResourceCache]::GetUriHash($Uri)
        $_match = [ResourceCache]::CachedResources | Where-Object { $_.Name -eq $_hash }

        # If a match is found, let's return the resource
        if ($_match.Count -eq 1)
        {
            # Return the match
            [ResourceCache]::Statistics.CacheHits += 1
            $_result = $_match
        }

        # Else, fetch the resource and make a recursive call
        else
        {
            try
            {
                [ResourceCache]::Statistics.CacheMisses += 1
                [ResourceCache]::AddResource($Uri)
                $_result = [ResourceCache]::GetResource($Uri)
            }
            catch
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogError(
                    "Unable to return a reference to the resource.")
                throw $_.Exception
            }
        }

        return $_result
    }

    # Returns a PSCustomObject from the ::Statistics array.
    # This method does not throw any custom exception.
    static [PSCustomObject] GetStatistics()
    {
        return New-Object `
            -Type "PSCustomObject" `
            -Property ([ResourceCache]::Statistics)
    }

    # Returns a MD5 hash from a Uri instance
    # Throws:
    #   - [RCHashGenerationFailureException] on failure.
    static [string] GetUriHash([System.Uri] $Uri)
    {
        [PSCustomObject] $_hash = $null

        try
        {
            $_encoder = [System.Text.UTF8Encoding]::New()
            $_stream  = [System.IO.MemoryStream]::new(
                $_encoder.GetBytes(
                    $Uri.AbsoluteUri))
            $_hash = Get-FileHash -Algorithm MD5 -InputStream $_stream
        }
        catch [System.ArgumentException]
        {
            throw [RCHashGenerationFailureException]::New(
                "md5", $Uri.AbsoluteUri)
        }

        return $_hash.Hash
    }

    # Removes a cached document from the cache and the disk
    # Does not throw any custom exception.
    static [void] RemoveCachedResource([System.IO.FileInfo] $CacheFile)
    {
        # Remove the cache file
        if ($CacheFile.Exists)
        {
            $CacheFile.File | Remove-Item -Force
        }

        # Remove the instance
        [ResourceCache]::CachedResources = (
            [ResourceCache]::CachedResources |
                Where-Object { $_.FullName -ne $CacheFile.FullName })

        # Update statistics
        [ResourceCache]::Statistics.RemovedResources += 1
    }

    # Force the removal of all expired resources. 
    # This method does not throw any custom exception.
    static [void] RemoveExpiredCachedResources()
    {
        foreach ($_cachedResource in [ResourceCache]::CachedResources)
        {            
            $_secondsSpent = (
                (Get-Date) - $_cachedResource.LastWriteTime).TotalSeconds
            $_TTL = [ResourceCache]::ResourceLifetime - $_secondsSpent

            if ($_TTL -le 0)
            {
                [EventLogger]::LogVerbose(
                    "Removing expired resource (TTL: {0}) at: {1}" `
                    -f @($_TTL, $_cachedResource.FullName))
                [ResourceCache]::RemoveCachedResource($_cachedResource)
            }
        }
    }

    # Removes any cached resource from the cache and resets statistics.
    # This method does not throw any custom exception.
    static [void] Reset()
    {
        [ResourceCache]::CachedResources = @()
        [ResourceCache]::Statistics = (
            [ordered] @{
                CacheHits = 0;
                CacheMisses = 0;
                AddedResources = 0;
                ExpiredResources = 0;
                RemovedResources = 0;
        })
    }

    # Loads cached files present in the cache folder.
    # Does not throw any custom exception.
    static [void] Restore()
    {
        [EventLogger]::LogVerbose("Beginning resource cache restoration.")

        $_cacheFiles = Get-ChildItem -Path ([ResourceCache]::CacheFolder)
        [EventLogger]::LogVerbose(
            "Found {0} cached resource files." -f $_cacheFiles.Count)

        foreach ($_cacheFile in $_cacheFiles)
        {           
            # If the file is older than the resource lifetime, delete it.
            $_secondsSpent = (
                (Get-Date) - $_cacheFile.LastWriteTime).TotalSeconds
            if ($_secondsSpent -gt ([ResourceCache]::ResourceLifetime))
            {
                [EventLogger]::LogVerbose(
                    "Cached resource file is obsolete and will be deleted.")
                Remove-Item -Force -Path $_cacheFile.FullName
                continue
            }

            # Else, store a reference to the cached resource
            else
            {
                [ResourceCache]::CachedResources += $_cacheFile
            }
        }
    }
}