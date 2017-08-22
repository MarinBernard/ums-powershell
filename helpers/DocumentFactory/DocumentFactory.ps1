###############################################################################
#   Static class DocumentFactory
#==============================================================================
#
#   This class returns UmsDocument instances.
#
###############################################################################

class DocumentFactory
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Statistics
    static [hashtable] $Statistics = @{}

    ###########################################################################
    # Visible properties
    ###########################################################################

    ###########################################################################
    # Static constructor
    ###########################################################################

    static DocumentFactory()
    {
        # Reset statistics
        [DocumentFactory]::Reset()
    }

    ###########################################################################
    # API
    ###########################################################################

    # Create a new UmsDocument instance from the supplied URI.
    # Throws:
    #   - [DFResourceRetrievalFailureException] if the document cannot be
    #       retrieved at the specified Uri. Proxified from ::GetResource().
    #   - [DFNewDocumentFailureException] if the instance cannot be created.
    static [UmsDocument] NewDocument([System.Uri] $Uri)
    {
        # Try to fetch the remote resource
        try
        {
            $_resource = [DocumentFactory]::GetResource($Uri)
        }
        # Resource not found
        catch [DFResourceRetrievalFailureException]
        {
            throw [DFResourceRetrievalFailureException]::New($Uri)
        }

        # Try to create a UmsDocument instance
        [UmsDocument] $_document = $null
        try
        {
            $_document = [UmsDocument]::New($_resource, $Uri)
        }
        catch [UmsDocumentException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [DFNewDocumentFailureException]::New($Uri)
        }

        # Update statistics
        [DocumentFactory]::Statistics.CreatedDocuments += 1

        # Return the new instance
        return $_document
    }

    # Returns a UmsDocument instance from the supplied URI. This method
    # is the main entry point to the [DocumentFactory] class and acts as a
    # dispatch box to the [DocumentCache]. It first tries to obtain the
    # instance from the document cache. If no cached instance is available,
    # it calls the ::NewDocument() method to construct a new one, adds it
    # to the document, then returns it.
    # Throws:
    #   - [DFNewDocumentFailureException] if the method cannot get a new
    #       UmsDocument instance from the target document.
    #   - [DFResourceRetrievalFailureException] if the document cannot be
    #       retrieved. Proxified from the NewDocument() method.
    #   - [DFCacheDocumentFailureException] if the method cannot add a new
    #       UmsDocument instance to the cache.
    static [UmsDocument] GetDocument([System.Uri] $Uri)
    {
        # Try to get a cached version of the document
        [UmsDocument] $_document = $null
        try
        {
            $_document = [DocumentCache]::GetDocument($Uri)
        }
        catch [DCCacheMissException]
        {
            [EventLogger]::LogVerbose(
                "No cached document found for URI: {0}" -f $Uri.AbsoluteUri)
            # Do nothing; exception is expected.
        }

        # If a match is found, we return the document.
        if ($_document)
        {
            [DocumentFactory]::Statistics.CacheHits += 1
            
            return $_document
        }

        # Else, we need to fetch the document and add it to the cache.
        else
        {
            [DocumentFactory]::Statistics.CacheMisses += 1

            # Try to get a new UmsDocument instance
            [UmsDocument] $_document = $null
            try
            {
                $_document = [DocumentFactory]::NewDocument($Uri)
            }
            catch [DFResourceRetrievalFailureException]
            {
                # We do not log the exception here as retrieval failure may be
                # expected.
                throw ($_.Exception)
            }
            catch [DocumentFactoryException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [DFNewDocumentFailureException]::New($Uri)
            }

            # Try to cache the new UmsDocument instance
            try
            {
                [DocumentCache]::AddDocument($Uri, $_document)
            }
            catch [DocumentCacheException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [DFCacheDocumentFailureException]::New($Uri)
            }
            
            # Return the document
            return $_document
        }
    }

    # Fetches and returns a resource from a URI.
    # Throws:
    #   - [DFResourceRetrievalFailureException] if the resource cannot be 
    #       retrieved.
    #   - [DFResourceConversionFailureException] if the fetched resource cannot
    #       be converted to UTF-8.
    static [string] GetResource([System.Uri] $Uri)
    {
        # Verbose prefix
        $_verbosePrefix = "[DocumentFactory]::GetResource(): "

        # Returned object
        [Microsoft.PowerShell.Commands.WebResponseObject] $_response = $null

        # Fetch the target document
        try
        {
            [EventLogger]::LogVerbose(
                "About to retrieve a document from URI: {0}" `
                -f $Uri.AbsoluteUri)
            
            $_response = Invoke-WebRequest -Uri $Uri -UseBasicParsing
        }
        catch [System.Net.WebException]
        {
            [DocumentFactory]::Statistics.FetchFailures += 1
            throw [DFResourceRetrievalFailureException]::New($Uri)
        }
        
        [DocumentFactory]::Statistics.FetchSuccesses += 1

        # Convert the resource body to UTF-8
        try
        {
            $_convertedResponse = (
                [System.Text.Encoding]::UTF8.GetString(
                    $_response.Content))
        }
        catch [System.ArgumentException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [DFResourceConversionFailureException]::New($Uri)
        }

        return $_convertedResponse 
    }

    # Returns a PSCustomObject from the ::Statistics array.
    # This method does not throw any custom exception.
    static [PSCustomObject[]] GetStatistics()
    {
        return New-Object `
            -Type "PSCustomObject" `
            -Property ([DocumentFactory]::Statistics)
    }

    # Resets statistics.
    # This method does not throw any custom exception.
    static [void] Reset()
    {
        [DocumentFactory]::Statistics = (
            [ordered] @{
                FetchFailures = 0;
                FetchSuccesses = 0;
                CacheHits = 0;
                CacheMisses = 0;
                CreatedDocuments = 0;
        })
    }
}