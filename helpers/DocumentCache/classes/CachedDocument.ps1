###############################################################################
#   Concrete class CachedDocument
#==============================================================================
#
#   This class describes a cached UMS resource. A UMS resource in an in-memory
#   representation of a UMS document.
#
###############################################################################

class CachedDocument
{
    ###########################################################################
    # Visible properties
    ###########################################################################

    # The on-disk file from which the instance was created.
    [System.IO.FileInfo] $File

    # The MD5 hash of the absolute URI. This is used as a resource UID within
    # the cache database.
    [string] $Hash    

    # The date and time at which the source file was created
    [DateTime] $CreationTime

    # Cache lifetime, in seconds
    [int] $Lifetime

    # The main UMS document
    [UmsDocument] $Document

    # Status of the cached document
    [CachedDocumentStatus] $Status
    
    # The number of seconds left before the document is marked as expired
    [int] $TTL    

    ###########################################################################
    # Constructors
    ###########################################################################

    # Constructs a new instance from a path to a document file, without a URI.
    # This constructor is called by the ::Restore() method of the DocumentCache
    # as it cannot provide the source original URI of the cached document.
    # Throws: same exceptions as ConstructCachedDocument()
    CachedDocument([System.IO.FileInfo] $File, [int] $Lifetime)
    {
        [EventLogger]::LogVerbose(
            "Creating a new UmsCachedDocument instance without a source URI.")
        
        $this.ConstructCachedDocument($File, $Lifetime)
    }

    # Constructs a new instance from a path to a document file, with a supplied
    # URI. This constructor is called by the ::AddDocument() method of the
    # [DocumentCache], which is able to provide the original source URI of the
    # document to the constructor.
    # Throws: same exceptions as ConstructCachedDocument()
    CachedDocument(
        [System.IO.FileInfo] $File, [int] $Lifetime, [System.Uri] $Uri)
    {
        [EventLogger]::LogVerbose(
            "Creating a new UmsCachedDocument instance with source URI: {0}" `
            -f $Uri.AbsoluteUri)

        $this.ConstructCachedDocument($File, $Lifetime)
        $this.UpdateSourceUri($Uri)
    }

    ###########################################################################
    # Sub-constructors
    ###########################################################################

    # Actual constructor. Called by all constructor overloads, as this method
    # does much of the construction job of the instance.
    # Throws:
    #   - [CDConstructionFailureException] on construction failure.
    [void] ConstructCachedDocument([System.IO.FileInfo] $File, [int] $Lifetime)
    {
        [EventLogger]::LogVerbose(
            ("Constructing the UmsCachedDocument instance from file: {0}" `
            -f $File.FullName))

        $this.File = $File.FullName
        $this.Hash = $File.Name
        $this.CreationTime = $File.LastWriteTime

        # Update caching status
        [EventLogger]::LogVerbose("Updating caching properties and statistics.")
        $this.Lifetime = $Lifetime
        $this.UpdateLifetimeStatistics()

        # We only read the XML document if the caching status is still current
        if ($this.Status -eq [CachedDocumentStatus]::Current)
        {
            [EventLogger]::LogVerbose("Instantiating the cached document.")
            try
            {
                $this.Document = $this.ParseCacheFile()
            }
            catch [CachedDocumentException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [CDConstructionFailureException]::New($File.FullName)
            }
        }
    }

    ###########################################################################
    # API
    ###########################################################################

    # Returns the cached UMS document
    [UmsDocument] GetDocument()
    {
        return $this.Document
    }

    [void] UpdateLifetimeStatistics()
    {
        # Update TTL
        $_secondsSpent = ((Get-Date) - $this.CreationTime).TotalSeconds
        $this.TTL = $this.Lifetime - $_secondsSpent

        # Update caching status
        if ($this.TTL -gt 0)
        {
            $this.Status = [CachedDocumentStatus]::Current
        }
        else
        {
            $this.Status = [CachedDocumentStatus]::Expired
        }
    }

    # Updates the SourceUri property of the [UmsDocument] instance. This method
    # may only be called once in the lifetime of the cached object, as allows
    # the [DocumentCache] class to re-inject the source Uri of a cached
    # document on first retrieval.
    # Throws:
    #   - [CDSourceUriUpdateFailureException] on source URI update failure.
    [void] UpdateSourceUri([System.Uri] $Uri)
    {
        [EventLogger]::LogVerbose("Updating Source URI.")
        try
        {
            $this.Document.UpdateSourceUri($Uri)
        }
        catch [UDDuplicateSourceUriUpdateException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [CDSourceUriUpdateFailureException]::New($Uri)
        }
    }

    ###########################################################################
    # API
    ###########################################################################

    # Parses the source file and returns a UmsDocument instance. Needed at
    # construction time.
    # Throws:
    #   - [CDFileReadFailureException] if the file content cannot be parsed.
    #   - [CDFileParseFailureException] if the file contains an invalid document
    [UmsDocument] ParseCacheFile()
    {
        [EventLogger]::LogVerbose("Beginning to parse the source cache file.")
        
        # Try to read file content
        [string] $_fileContent = $null
        try
        {
            $_fileContent = [System.IO.File]::ReadAllText($this.File)
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [CDFileReadFailureException]::New($this.File.FullName)
        }

        # Try to create a new UmsDocument instance
        [EventLogger]::LogVerbose("Creating UmsDocument instance.")
        [UmsDocument] $_document = $null
        try
        {
            $_document = [UmsDocument]::New($_fileContent)
        }
        catch [UmsDocumentException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [CDFileParseFailureException]::New($this.File.FullName)
        }

        # Return the instance
        [EventLogger]::LogVerbose("Finished parsing the source cache file.")
        return $_document
    }


}

Enum CachedDocumentStatus
{
    Current
    Expired
}