###############################################################################
#   Static class DocumentCache
#==============================================================================
#
#   This class implements a caching mechanism for UMS documents.
#
###############################################################################

class DocumentCache
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # The lifetime of all cached documents
    static $DocumentLifetime = (
        [ConfigurationStore]::GetSystemItem(
            "DocumentCacheLifeTime").Value)

    # The cache itself
    static [CachedDocument[]] $CachedDocuments = @()

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
    #   - [DCCacheDirectoryCreationFailureException] on cache directory
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
            # Disable on-disk persistence on cache folder creation failure
            catch [System.IO.IOException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [DCCacheDirectoryCreationFailureException]::New(
                    $CacheFolder)
            }
        }

        # Store a new instance of the cache folder
        [DocumentCache]::CacheFolder = (
            [System.IO.DirectoryInfo] $CacheFolder.FullName)

        # Initialize document cache and cache statistics
        [DocumentCache]::Reset()

        # Populate the cache
        [DocumentCache]::Restore()
    }

    ###########################################################################
    # Sub-constructors
    ###########################################################################

    ###########################################################################
    # API
    ###########################################################################

    # Adds a document to the cache with an associated URI.
    # Throws:
    #   - [DCCacheWriteFailureException] if the document cannot be added to
    #       the on-disk cache.
    #   - [DCNewCachedDocumentFailureException] if the document cannot be
    #       cached because of a failure of the [CachedDocument] constructor.
    static [void] AddDocument([System.Uri] $Uri, [UmsDocument] $Document)
    {        
        # Build the reference to the cache file
        [System.IO.FileInfo] $_cacheFile = [DocumentCache]::GetCacheFile($Uri)

        [EventLogger]::LogVerbose(
            ("Cache file full name: {0}" -f $_cacheFile.FullName))

        # Try to save the new cache file
        try
        {
            $Document.ToXmlString() | Out-File `
                -Encoding UTF8 `
                -Force `
                -FilePath $_cacheFile `
                -ErrorAction Stop
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            Remove-Item -Path $_cacheFile -Force
            throw [DCCacheWriteFailureException]::New($Uri, $_cacheFile)
        }

        # Create a CachedDocument instance from the cache file
        [CachedDocument] $_cachedDocument = $null
        try
        {
            $_cachedDocument = [CachedDocument]::New(
                $_cacheFile,
                [DocumentCache]::DocumentLifetime,
                $Uri)
        }
        catch [CachedDocumentException]
        {
            [EventLogger]::LogException($_.Exception)
            Remove-Item -Path $_cacheFile -Force
            throw [DCNewCachedDocumentFailureException]::New($_cacheFile)
        }

        [DocumentCache]::Statistics.AddedDocuments += 1
        [DocumentCache]::CachedDocuments += $_cachedDocument
    }

    # Returns the whole CachedDocuments collection after a TTL update.
    # This method does not throw any custom exception.
    static [CachedDocument[]] Dump()
    {
        [DocumentCache]::RemoveExpiredCachedDocuments()
        return [DocumentCache]::CachedDocuments
    }

    # Force the removal of all expired documents but keeps statistics
    # This method does not throw any custom exception.
    static [void] Flush()
    {
        foreach ($_cachedDocument in [DocumentCache]::CachedDocuments)
        {
            [DocumentCache]::RemoveCachedDocument($_cachedDocument)
        }
    }

    # Returns a reference to a cache file from a resource URI.
    # Throws:
    #   - [DCGetCacheFileFailureException] on fatal failure.
    static [System.IO.FileInfo] GetCacheFile([System.Uri] $Uri)
    {
        # Try to build the name of the cache file
        [string] $_hash = $null
        try
        {
            $_hash = [DocumentCache]::GetUriHash($Uri)
        }
        catch [DCHashGenerationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [DCGetCacheFileFailureException]::New($Uri)
        }

        [EventLogger]::LogDebug(("Computed hash is: {0}" -f $_hash))

        # Try to build the full path to the cache file
        [string] $_path = $null
        try
        {
            $_path = Join-Path `
                -Path ([DocumentCache]::CacheFolder) `
                -ChildPath $_hash `
                -ErrorAction Stop
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [DCGetCacheFileFailureException]::New($Uri)
        }

        return [System.IO.FileInfo] $_path
    }

    # Returns a cached document from its URI. If the cached document is not
    # present in the cache, it is fetched and cached, then the method is called
    # again recursively.
    # Throws:
    #   - [DCCacheMissException] on cache miss.
    #   - [DCSourceUriUpdateFailureException] on source URI update failure.
    static [UmsDocument] GetDocument([System.Uri] $Uri)
    {
        $_hash  = [DocumentCache]::GetUriHash($Uri)
        $_match = [DocumentCache]::CachedDocuments | Where-Object { $_.Hash -eq $_hash }

        # If a match is found, let's validate the caching status, and return
        # the document.
        if ($_match.Count -eq 1)
        {
            # Update the SourceUri of the UmsDocument instance, if needed
            if ($_match.Document.SourceUriStatus -ne [UmsDocumentSourceUriStatus]::Present)
            {
                try
                {
                    $_match.UpdateSourceUri($Uri)
                }
                catch [CDSourceUriUpdateFailureException]
                {
                    [EventLogger]::LogException($_.Exception)
                    throw [DCSourceUriUpdateFailureException]::New($Uri)
                }
            }

            # Update caching status of the CachedDocument instance
            $_match.UpdateLifetimeStatistics()

            # Return the match
            if ($_match.Status -eq [CachedDocumentStatus]::Current)
            {
                [DocumentCache]::Statistics.CacheHits += 1
                return $_match.GetDocument()
            }

            # Remove the expired document from the cache.
            else
            {
                # Update statistics
                [DocumentCache]::Statistics.ExpiredDocuments += 1
                # Remove expired document
                [DocumentCache]::RemoveCachedDocument($_match)
                # Recursive call to get fresh copy
                return [DocumentCache]::GetDocument($Uri)
            }
        }

        # Else, we we have nothing to return and throw an exception
        else
        {
            [DocumentCache]::Statistics.CacheMisses += 1
            throw [DCCacheMissException]::New($Uri)
        }
    }

    # Returns a PSCustomObject from the ::Statistics array.
    # This method does not throw any custom exception.
    static [PSCustomObject[]] GetStatistics()
    {
        return New-Object `
            -Type "PSCustomObject" `
            -Property ([DocumentCache]::Statistics)
    }

    # Returns a MD5 hash from a Uri instance
    # Throws [DCHashGenerationFailureException] on failure.
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
            throw [DCHashGenerationFailureException]::New(
                "md5", $Uri.AbsoluteUri)
        }

        return $_hash.Hash
    }

    # Removes a cached document from the cache and the disk
    # Does not throw any custom exception.
    static [void] RemoveCachedDocument([CachedDocument] $CachedDocument)
    {
        # Remove the cache file
        if ($CachedDocument.File.Exists)
        {
            $CachedDocument.File | Remove-Item -Force
        }

        # Remove the instance
        [DocumentCache]::CachedDocuments = (
            [DocumentCache]::CachedDocuments |
                Where-Object { $_ -ne $CachedDocument })

        # Update statistics
        [DocumentCache]::Statistics.RemovedDocuments += 1
    }

    # Removes a document from the cache and the disk
    # Does not throw any custom exception.
    static [void] RemoveDocument([System.Uri] $Uri)
    {
        # Get the URI hash
        try
        {
            $_hash = [DocumentCache]::GetUriHash($Uri)
        }
        catch [DCHashGenerationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            return
        }

        # Search the cache
        [CachedDocument] $_match = [DocumentCache]::CachedDocuments |
            Where-Object { $_.Hash -eq $_hash }

        # Remove the document
        if ($_match)
        {
            [DocumentCache]::RemoveCachedDocument($_match)
        }
    }

    # Force the removal of all expired documents 
    # This method does not throw any custom exception.
    static [void] RemoveExpiredCachedDocuments()
    {
        foreach ($_cachedDocument in [DocumentCache]::CachedDocuments)
        {
            $_cachedDocument.UpdateLifetimeStatistics()
            
            if ($_cachedDocument.Status -eq [CachedDocumentStatus]::Expired)
            {
                # Update statistics
                [DocumentCache]::Statistics.ExpiredDocuments += 1

                # Remove document
                [DocumentCache]::RemoveCachedDocument($_cachedDocument)
            }
        }
    }

    # Removes any cached document from the cache and resets statistics.
    # This method does not throw any custom exception.
    static [void] Reset()
    {
        [DocumentCache]::CachedDocuments = @()
        [DocumentCache]::Statistics = (
            [ordered] @{
                CacheHits = 0;
                CacheMisses = 0;
                AddedDocuments = 0;
                ExpiredDocuments = 0;
                InvalidDocuments = 0;
                RemovedDocuments = 0;
        })
    }

    # Loads cached files present in the cache folder.
    # Does not throw any custom exception, but outputs all
    # [CachedDocumentException] as error messages.
    static [void] Restore()
    {
        [EventLogger]::LogVerbose("Beginning cache restoration.")

        $_cacheFiles = Get-ChildItem -Path ([DocumentCache]::CacheFolder)
        [EventLogger]::LogVerbose(
            "Found {0} caches files to restore." -f $_cacheFiles.Count)

        foreach ($_cacheFile in $_cacheFiles)
        {
            [EventLogger]::LogVerbose(
                "Restoring file: {0}" -f $_cacheFile.FullName)
            
            # If the file is older than the document lifetime, delete it.
            $_secondsSpent = (
                (Get-Date) - $_cacheFile.LastWriteTime).TotalSeconds
            if ($_secondsSpent -gt ([DocumentCache]::DocumentLifetime))
            {
                [EventLogger]::LogVerbose(
                    "Cache file is obsolete and will be deleted.")
                Remove-Item -Force -Path $_cacheFile.FullName
                continue
            }

            # Else, create and store a CachedDocument instance
            try
            {
                [DocumentCache]::CachedDocuments = (
                    [CachedDocument]::New(
                        $_cacheFile,
                        [DocumentCache]::DocumentLifetime))
            }
            # Skip and delete the file on instantiation failure
            catch [CachedDocumentException]
            {
                [DocumentCache]::Statistics.InvalidDocuments += 1
                [EventLogger]::LogException($_.Exception)
                $_cacheFile | Remove-Item -Force
            }
        }
    }
}