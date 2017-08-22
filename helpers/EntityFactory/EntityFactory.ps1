###############################################################################
#   Static factory class EntityFactory
#==============================================================================
#
#   This class is a factory in charge of instantiating entity classes derivated
#   from the UmsEntity parent class. The class decides which entity type to
#   instantiate from the local name and namespace URI of the supplied XML
#   document. It feeds and queries the [EntityCache] utility class to avoid
#   instantiating the same entity twice.
#
###############################################################################

class EntityFactory
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Stores statistics about the entity factory
    static [hashtable] $Statistics   

    # Extension of UMS items
    static [string] $UmsFileExtension = (
        [ConfigurationStore]::GetSystemItem("UmsFileExtension").Value)

    ###########################################################################
    # Static constructor
    ###########################################################################

    static EntityFactory()
    {
        # Initialize statistics
        [EntityFactory]::Reset()
    }

    ###########################################################################
    # Factory method
    ###########################################################################

    # Main entry point of the class. This method converts a UmsDocument
    # instance to a single entity tree. It is called as many times as the UMS
    # document references external UMS documents.
    # Throws:
    #   - [EFProcessDocumentFailureException] when the document cannot be
    #       parsed.
    static [UmsAeEntity] ProcessDocument(
        [UmsDocument] $Document,
        [string] $Uid)
    {
        [EventLogger]::LogVerbose(
            "Began processing document with URI: {0}" -f $Document.SourceUri.AbsoluteUri)
        
        # Build source path URI (hacky but works)
        $_sourcePathUri = [System.Uri]::New(
            $Document.SourceUri.AbsoluteUri.Substring(
                0,
                $Document.SourceUri.AbsoluteUri.Length - $Document.SourceUri.Segments[-1].Length
            )).AbsoluteUri
        
        [EventLogger]::LogVerbose(
            "Built source path URI: {0}" -f $_sourcePathUri)

        # Add transclusion attributes to the element.
        # "src" attribute is the absolute URI to the source document.
        $Document.MainElement.SetAttribute("src", $Document.SourceUri)
        # "uid" attribute is the same as the uid of the transcluded reference.
        if ($Uid) { $Document.MainElement.SetAttribute("uid", $Uid) }

        # Start entity instantation
        [EventLogger]::LogVerbose("Starting entity instantiation")
        [UmsAeEntity] $_entity = $null
        try
        {
            $_entity = (
                [EntityFactory]::GetEntity(
                    $Document.MainElement,
                    $_sourcePathUri,
                    $Document.SourceUri))
        }
        catch [EFClassLookupFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [EFProcessDocumentFailureException]::New($Document.SourceUri)
        }
        catch [EntityFactoryException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [EFProcessDocumentFailureException]::New($Document.SourceUri)
        }
        catch [UmsEntityException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [EFProcessDocumentFailureException]::New($Document.SourceUri)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogVerbose("An unknown exception was caught.")
            throw [EFProcessDocumentFailureException]::New($Document.SourceUri)
        }

        # Return instantiated entity
        return $_entity
    }

    # Returns an instance of an entity class. The method first queries the
    # entity cache. If no cached entity is found, it calls the ::NewEntity()
    # to create a new entity instance, adds it to the entity cache, before
    # returning it to the caller.
    # Throws:
    #   - [EFNullXmlElementException] if the Xml element is null.
    #   - [EFCacheFailureException] if the EntityCache class throws a fatal
    #       failure exception.
    #   - [EFUnsupportedXmlElementException] if the XML element cannot be
    #       resolved by the NewEntity() method.
    #   - [EFEntityInstantiationFailureException] when the constructor of
    #       an entity threw an unhandled exception.
    #   - [EFUnresolvableReferenceException] if a UMS reference cannot be
    #       resolved (proxified from the ::GetReferenceTargetUri() method).
    #   - [EntityFactoryException] on internal failure.
    static [UmsAeEntity] GetEntity(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourcePathUri,
        [string] $SourceFileUri)
    {
        [EventLogger]::LogVerbose(
            "New entity query for element '{0}' from namespace '{1}'." `
            -f @($XmlElement.LocalName,$XmlElement.NamespaceURI))
        [EventLogger]::LogVerbose("Source path URI is: {0}" -f $SourcePathUri)
        [EventLogger]::LogVerbose("Source file URI is: {0}" -f $SourceFileUri)

        # If the Xml element is null, we halt there
        if ($XmlElement -eq $null)
        {
            [EventLogger]::LogVerbose("Xml element is null!")
            throw [EFNullXmlElementException]::New(
                $XmlElement, $SourcePathUri, $SourceFileUri)
        }

        # Get element type
        if ($XmlElement.GetAttribute("uid"))
        {
            if ($XmlElement.ChildNodes.Count -eq 0)
            {
                $_elementType = [UmsXmlElementType]::ReferenceElement
            }
            else
            {
                $_elementType = [UmsXmlElementType]::ReferenceableElement
            }
        }
        else
        {
            $_elementType = [UmsXmlElementType]::SimpleElement
        }
        [EventLogger]::LogVerbose("UMS element type: {0}" -f $_elementType)

        # Check whether the element is eligible to caching
        $_cacheableElements = @(
            [UmsXmlElementType]::ReferenceElement,
            [UmsXmlElementType]::ReferenceableElement)
        if ($_cacheableElements -contains($_elementType))
        {
            $_isCacheable = $true
            [EventLogger]::LogVerbose(
                "The XML element is eligible to entity caching")
        }
        else
        {
            $_isCacheable = $false
            [EventLogger]::LogVerbose(
                "The XML element is not eligible to entity caching")
        }

        # If the element is cacheable, try to get an instance from the cache
        if ($_isCacheable)
        {
            [EventLogger]::LogVerbose("Trying to get a cached entity instance.")
            [UmsAeEntity] $_entity = $null
            try
            {
                $_entity = (
                    [EntityCache]::GetEntity($XmlElement, $SourceFileUri))
            }
            catch [ECNoMatchException]
            {
                # Recoverable failure
                [EventLogger]::LogVerbose(
                    "No entity instance was available in the cache")
            }
            catch [EntityCacheException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [EFCacheFailureException]::New()
            }

            # If an instance was returned, we return it.
            if ($_entity)
            {
                [EventLogger]::LogVerbose("Returning cached entity instance.")
                return $_entity
            }
        }

        # If we land here, it means no cached instance of the entity exists,
        # and we must instantiate a new one.

        # If the Xml element describes a simple or referenceabvle element,
        # we may try instantiation right now as no transclusion is needed.
        
        if (@(
            [UmsXmlElementType]::SimpleElement,
            [UmsXmlElementType]::ReferenceableElement) -contains(
                $_elementType))
        {
            [EventLogger]::LogVerbose(
                "The XML element does not need transclusion.")

            # Try to instantiate a new entity from the element.
            [UmsAeEntity] $_entity = $null
            try
            {
                $_entity = [EntityFactory]::NewEntity(
                    $XmlElement, $SourceFileUri)
            }
            catch [EFClassLookupFailureException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [EFUnsupportedXmlElementException]::New()
            }
            catch [UmsEntityException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [EFEntityInstantiationFailureException]::New()
            }
            catch
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogVerbose("An unknown exception was caught.")
                throw [EFEntityInstantiationFailureException]::New()
            }
        }

        # Else, the Xml element describes a UMS reference. We need to obtain
        # a UmsDocument instance representing the resource targeted by the
        # UMS reference.
        else
        {
            [EventLogger]::LogVerbose("The XML element requires transclusion.")

            # Try to obtain the UmsDocument matching the UMS reference
            [UmsDocument] $_document = $null
            try
            {
                $_document = [EntityFactory]::GetReferenceTargetDocument(
                    $XmlElement, $SourcePathUri)
            }
            catch [EFUnresolvableReferenceException]
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogVerbose("The UMS reference is unresolvable.")
                throw $_.Exception
            }
            catch [EntityFactoryException]
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogVerbose("Internal failure.")
                throw $_.Exception
            }

            # Creating an entity from the document.
            [UmsAeEntity] $_entity = $null
            try
            {
                $_entity = (
                    [EntityFactory]::ProcessDocument(
                        $_document,
                        $XmlElement.GetAttribute("uid")))
            }
            catch [EFProcessDocumentFailureException]
            {
                [EventLogger]::LogException($_.Document)
                throw [EFEntityInstantiationFailureException]::New()
            }
        }

        # If we land here, an new, non-cached entity instance must be available
        # in the $_entity variable. We need to cache it before returning it.
        if ($_isCacheable)
        {
            try
            {
                [EntityCache]::AddEntity($_entity)
            }
            catch
            {
                # We continue on cache failure.
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogError("Unable to cache the entity!")
            }
        }

        # Return the entity
        return $_entity
    }

    # Returns the URI to the document targeted by a UMS reference. This method
    # is responsible for resolving a UMS reference to a valid URI.
    # Parameters:
    #   - $XmlElement is the Xml element describing the UMS reference.
    #   - $SourcePathUri is the absolute URI to the parent container of the
    #       source file from which $XmlElement was extracted. This parameter
    #       allows the method to find remote documents with a relative path.
    # Throws:
    #   - [EFUnresolvableReferenceException] when the reference cannot be
    #       resolved.
    #   - [EFDocumentFactoryFailureException] when the [DocumentFactory]
    #       encounters an fatal failure.
    static [UmsDocument] GetReferenceTargetDocument(
        [System.Xml.XmlElement] $XmlElement,
        [string] $SourcePathUri
    )
    {
        # Log reference resolution
        [EventLogger]::LogVerbose(
            "Beginning the resolution of a UMS reference.")
        [EventLogger]::LogVerbose(
            "Source path URI is: {0}" -f $SourcePathUri)
        [EventLogger]::LogVerbose(
            "Reference UID is: {0}" -f $XmlElement.GetAttribute("uid"))
        [EventLogger]::LogVerbose(
            "Reference XML namespace is: {0}" -f $XmlElement.NamespaceURI)
        [EventLogger]::LogVerbose(
            "Reference local name is: {0}" -f $XmlElement.LocalName)

        # Gather all URI candidates
        [System.Uri[]] $_uris = [EntityFactory]::GetAllCandidateUri(
            $XmlElement, $SourcePathUri)

        # Test each candidate. First instantiated document wins.
        [UmsDocument] $_document = $null
        foreach ($_uri in $_uris)
        {
            try
            {
                $_document = [DocumentFactory]::GetDocument($_uri)
            }
            catch [DFResourceRetrievalFailureException]
            {
                # This exception is expected, and means that the candidate URI
                # failed, since the resource could not be retrieved.
                [EventLogger]::LogVerbose(
                    "The following candidate URI could not be retrieved: {0}" `
                    -f $_uri.AbsoluteUri)
            }
            catch [DocumentFactoryException]
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogVerbose(
                    "Unexpected failure of the document factory.")
                throw [EFDocumentFactoryFailureException]::New()
            }

            # If a match is found, we return the document
            if ($_document)
            {
                [EventLogger]::LogVerbose(
                    "The following candidate URI was elected: {0}" `
                    -f $_uri.AbsoluteUri)
                return $_document
            }
            else
            {
                [EventLogger]::LogVerbose(
                    "The following candidate URI was discarded: {0}" `
                    -f $_uri.AbsoluteUri)
            }
        }

        # If we get there, the reference is declared unresolvable;
        throw [EFUnresolvableReferenceException]::New(
            $XmlElement, $SourcePathUri)
    }

    ###########################################################################
    # API
    ###########################################################################

    # Creates and returns a new entity instance from an Xml element.
    # Parameters:
    #   - $XmlElement is the source XML element from which the entity will be
    #       instantiated.
    #   - $Uri is the absolute URI to the source file from which the calling
    #       entity was instantiated.
    # Throws:
    #   - [EFEntityInstantiationFailureException] if an entity construction
    #       failed.
    #   - [EFClassLookupException] if no matching class is found.
    static [UmsAeEntity] NewEntity(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $Uri)
    {
        [EventLogger]::LogVerbose("Creating a new entity instance.")
        [EventLogger]::LogVerbose("Source document URI is: {0}" -f $Uri)
        [EventLogger]::LogVerbose($(
            "Beginning entity instantiation from element '{0}' " + `
            "from namespace '{1}'") `
            -f @($XmlElement.LocalName, $XmlElement.NamespaceURI))

        try
        {
            # Audio namespace
            if (
                $XmlElement.NamespaceUri -eq 
                    [UmsAeEntity]::NamespaceUri["Audio"])
            {
                switch ($XmlElement.LocalName)
                {
                    "album"
                        { return New-Object -Type UmsAceAlbum(
                            $XmlElement, $Uri) }
                    "albumTrackBinding"
                        { return New-Object -Type UmsAbeAlbumTrackBinding(
                            $XmlElement, $Uri) }
                    "label"
                        { return New-Object -Type UmsAceLabel(
                            $XmlElement, $Uri) }
                    "medium"
                        { return New-Object -Type UmsAceMedium(
                            $XmlElement, $Uri) }               
                }
            }

            # Base namespace
            elseif (
                $XmlElement.NamespaceUri -eq
                    [UmsAeEntity]::NamespaceUri["Base"])
            {
                switch ($XmlElement.LocalName)
                {
                    "birth"
                        { return New-Object -Type UmsBceBirth(
                            $XmlElement, $Uri) }
                    "character"
                        { return New-Object -Type UmsBceCharacter(
                            $XmlElement, $Uri) }                    
                    "city"
                        { return New-Object -Type UmsBceCity(
                            $XmlElement, $Uri) }
                    "completion"
                        { return New-Object -Type UmsBceCompletion(
                            $XmlElement, $Uri) }
                    "country"
                        { return New-Object -Type UmsBceCountry(
                            $XmlElement, $Uri) }
                    "countryDivision"
                        { return New-Object -Type UmsBceCountryDivision(
                            $XmlElement, $Uri) }
                    "death"
                        { return New-Object -Type UmsBceDeath(
                            $XmlElement, $Uri) }
                    "inception"
                        { return New-Object -Type UmsBceInception(
                            $XmlElement, $Uri) }
                    "labelVariant"
                        { return New-Object -Type UmsBceLabelVariant(
                            $XmlElement, $Uri) }
                    "linkVariant"
                        { return New-Object -Type UmsBceLinkVariant(
                            $XmlElement, $Uri) }
                    "nameVariant"
                        { return New-Object -Type UmsBceNameVariant(
                            $XmlElement, $Uri) }
                    "place"
                        { return New-Object -Type UmsBcePlace(
                            $XmlElement, $Uri) }
                    "release"
                        { return New-Object -Type UmsBceRelease(
                            $XmlElement, $Uri) }
                    "standard"
                        { return New-Object -Type UmsBceStandard(
                            $XmlElement, $Uri) }
                    "standardId"
                        { return New-Object -Type UmsBceStandardId(
                            $XmlElement, $Uri) }
                    "symbolVariant"
                        { return New-Object -Type UmsBceSymbolVariant(
                            $XmlElement, $Uri) }
                    "titleVariant"
                        { return New-Object -Type UmsBceTitleVariant(
                            $XmlElement, $Uri) }
                }
            }

            # Music namespace
            elseif (
                $XmlElement.NamespaceUri -eq
                    [UmsAeEntity]::NamespaceUri["Music"])
            {
                switch ($XmlElement.LocalName)
                {
                    "catalog"
                        { return New-Object -Type UmsMceCatalog(
                            $XmlElement, $Uri) }
                    "catalogId"
                        { return New-Object -Type UmsMceCatalogId(
                            $XmlElement, $Uri) }
                    "composer"
                        { return New-Object -Type UmsMceComposer(
                            $XmlElement, $Uri) }
                    "conductor"
                        { return New-Object -Type UmsMceConductor(
                            $XmlElement, $Uri) }
                    "ensemble"
                        { return New-Object -Type UmsMceEnsemble(
                            $XmlElement, $Uri) }                    
                    "form"
                        { return New-Object -Type UmsMceForm(
                            $XmlElement, $Uri) }
                    "instrument"
                        { return New-Object -Type UmsMceInstrument(
                            $XmlElement, $Uri) }
                    "instrumentalist"
                        { return New-Object -Type UmsMceInstrumentalist(
                            $XmlElement, $Uri) }                    
                    "key"
                        { return New-Object -Type UmsMceKey(
                            $XmlElement, $Uri) }
                    "lyricist"
                        { return New-Object -Type UmsMceLyricist(
                            $XmlElement, $Uri) }   
                    "movement"
                        { return New-Object -Type UmsMceMovement(
                            $XmlElement, $Uri) }                    
                    "place"
                        { return New-Object -Type UmsMcePlace(
                            $XmlElement, $Uri) }
                    "performance"
                        { return New-Object -Type UmsMcePerformance(
                            $XmlElement, $Uri) }
                    "performer"
                        { return New-Object -Type UmsMcePerformer(
                            $XmlElement, $Uri) }
                    "piece"
                        { return New-Object -Type UmsMcePiece(
                            $XmlElement, $Uri) }
                    "premiere"
                        { return New-Object -Type UmsMcePremiere(
                            $XmlElement, $Uri) }
                    "score"
                        { return New-Object -Type UmsMceScore(
                        $XmlElement, $Uri) }
                    "section"
                        { return New-Object -Type UmsMceSection(
                            $XmlElement, $Uri) }
                    "style"
                        { return New-Object -Type UmsMceStyle(
                            $XmlElement, $Uri) }
                    "track"
                        { return New-Object -Type UmsMceTrack(
                            $XmlElement, $Uri) }  
                    "venue"
                        { return New-Object -Type UmsMceVenue(
                            $XmlElement, $Uri) }   
                    "work"
                        { return New-Object -Type UmsMceWork(
                            $XmlElement, $Uri) }
                }
            }

            # Increase instantiation count
            [EntityFactory]::Statistics.InstanceCreations += 1
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [EFEntityInstantiationFailureException]::New()
        }

        # Unknown namespace or element
        throw [EFClassLookupFailureException]::New($XmlElement)
    }

    # Resets the statistics of the entity factory.
    # This method does not throw any exception.
    static [void] Reset()
    {
        [EntityFactory]::Statistics = @{
            InstanceCreations = 0;
            CacheHits = 0;
            CacheMisses = 0;
            CacheSkips = 0;
        }
    }

    ###########################################################################
    # Transclusion methods
    ###########################################################################

    # Returns a list of candidate URIs to the XML UMS document targeted by
    # a UMS reference. The list includes URIs pointing to remote catalogs
    # as well as local resources.
    static [System.Uri[]] GetAllCandidateUri(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $SourcePathUri)
    {
        # Name and URI of the target UMS file
        $_fileName = $(
            $XmlElement.GetAttribute("uid") + `
            [EntityFactory]::UmsFileExtension)

        $_fileRelativeUri = (
            [System.Uri]::New($_fileName, [System.UriKind]::Relative))

        [EventLogger]::LogVerbose("Target file name is: {0}" -f $_fileName)
        
        # Gather a list of potential catalog sub-paths
        [System.Uri[]] $_uris = [EntityFactory]::GetCatalogCandidateUri(
            $XmlElement.NamespaceUri,
            $XmlElement.LocalName,
            $_fileRelativeUri)
        
        # Add candidate URIs built from relative paths
        $_uris += [System.Uri]::New($SourcePathUri, $_fileRelativeUri)
        
        # Log URI candidates
        foreach ($_uri in $_uris)
        {
            [EventLogger]::LogVerbose(
                "Got candidate URI: {0}" -f $_uri.AbsoluteUri)
        }

        # Return the list of candidate URIs
        return $_uris
    }

    # Returns a collection of locations which are candidate URIs to the XML UMS
    # document targeted by a UMS reference.
    static [System.Uri[]] GetCatalogCandidateUri(
        [string] $XmlNamespace,
        [string] $XmlElement,
        [System.Uri] $LeafUri)
    {
        [EventLogger]::LogVerbose($(
            "Searching candidate URIs in all configured catalogs " + `
            "for element '{0}' from namespace '{1}'") `
            -f @($XmlElement, $XmlNamespace))

        # The list of candidate URIs which will be returned by the method.
        [System.Uri[]] $_list = @()

        # Enumerating all known catalogs.
        foreach ($_catalog in [ConfigurationStore]::GetCatalogItem(""))
        {
            [EventLogger]::LogVerbose($(
                "Evaluating catalog with id '{0}' and namespace '{1}'") `
                -f @($_catalog.Id, $_catalog.XmlNamespace))

            # If the catalog is bound to the namespace of the UMS reference,
            # let's try to find a suitable sub-path.
            if ($_catalog.XmlNamespace -eq $XmlNamespace)
            {
                [EventLogger]::LogVerbose($(
                    "Catalog with id '{0}' matches the element namespace.") `
                    -f $_catalog.Id)
                
                # Catalog URI is assumed as absolute, and will be used as a
                # base path for all derived candidate URIs.
                $_catalogUri = [System.Uri]::New($_catalog.Uri)

                # Enumerating catalog sub-paths.
                foreach ($_mapping in $_catalog.Mappings)
                {
                    # If the catalog sub-path contains UMS elements of the
                    # same time as the target UMS reference, it will be
                    # included to the list of candidate locations.
                    if ($_mapping.Element -eq $XmlElement)
                    {
                        [EventLogger]::LogVerbose($(
                            "Mapping with sub-path '{0}' " + `
                            "matches element name.") `
                            -f $_mapping.SubPath)

                        # Building the absolute URI of the document in the
                        # current catalog sub-path.
                        $_mappingUri = (
                            [System.Uri]::New(
                                $($_mapping.SubPath + "/"),
                                [System.UriKind]::Relative))

                        [EventLogger]::LogVerbose(
                            "Sub-path relative URI is: {0}" -f $_mappingUri)
                        
                        $_subPathUri = [System.Uri]::New(
                            $_catalogUri, $_mappingUri)

                        [EventLogger]::LogVerbose(
                            "Sub-path absolute URI is: {0}" -f $_subPathUri)

                        $_candidateUri = [System.Uri]::New(
                            $_subPathUri, $LeafUri)

                        [EventLogger]::LogVerbose(
                            "Candidate absolute URI is: {0}" -f $_candidateUri)

                        # Adding the URI to the list of candidate URIs
                        $_list += $_candidateUri
                    }
                }
            }
        }

        return $_list
    }
}

###############################################################################
#   Enum UmsXmlElementType
#==============================================================================
#
#   This enum stores the list of all Xml element types in a UMS context.
#
###############################################################################

Enum UmsXmlElementType
{
    ReferenceElement
    ReferenceableElement
    SimpleElement
}