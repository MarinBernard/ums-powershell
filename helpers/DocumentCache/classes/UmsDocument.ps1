###############################################################################
#   Class UmsDocument
#==============================================================================
#
#   This class describes a UMS document. It embeds a XmlDocument representation
#   of an UMS document, exposes various properties about the document, and
#   provides helper methods regarding document validation.
#
###############################################################################

class UmsDocument
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Catalog of namespace URIs.
    static [hashtable] $NamespaceUri = @{
        "Base"  = [ConfigurationStore]::GetSchemaItem("Base").Namespace;
        "Audio" = [ConfigurationStore]::GetSchemaItem("Audio").Namespace;
        "Music" = [ConfigurationStore]::GetSchemaItem("Music").Namespace;
    }

    ###########################################################################
    # Properties
    ###########################################################################

    # The in-memory XML representation of the UMS document.
    [System.Xml.XmlDocument] $XmlDocument

    # Uri to the source of the document. Set up at instance construction,
    # unless the instance is built by a CachedDocument instance. In that last
    # case, the SourceUri is blank, and will be updated at a later time by
    # the [DocumentCache] class.
    [System.Uri] $SourceUri

    # Uri to the authoritative schema file. Needed for validation.
    hidden [System.Uri] $SchemaFileUri

    # The naming status of the SourceURI property.
    [UmsDocumentSourceUriStatus] $SourceUriStatus

    # Properties describing the document element of the document.
           [string] $RootSchema         # Id of the doc element namespace
           [string] $RootName           # Full name of the document element
    hidden [string] $RootNamespace      # Namespace of the document element
    hidden [string] $RootLocalName      # Local name of the document elemnt
    hidden [System.Xml.XmlElement] `    # Reference to the document element
                    $RootElement

    # Properties describing the binding element of the document, if present.
           [string] $BindingSchema      # Id of the binding element namespace
           [string] $BindingName        # Full name of binding element, if any
    hidden [string] $BindingNamespace   # Namespace of binding element, if any
    hidden [string] $BindingLocalName   # Local name of binding elmnt, if any
    hidden [System.Xml.XmlElement] `    # Reference to the binding element
                    $BindingElement

    # Properties describing the main element of the document, if present.
    # If the document is a binding document, the main element is the binding
    # element. Otherwise, it is the document element.
           [string] $MainSchema         # Id of the main element namespace
           [string] $MainName           # Full name of the main element
    hidden [string] $MainNamespace      # Namespace of the main element
    hidden [string] $MainLocalName      # Local name of the main element
    hidden [System.Xml.XmlElement] `    # Reference to the main element
                    $MainElement

    # Whether the UMS document is a binding document
    [bool] $BindingDocument

    # Validation status of the document. Validation is CPU intensive, and does
    # not occur automatically. This property is set to Unknown by default, and
    # will show this value until validation is eventually triggered.
    [UmsDocumentValidity] $Validity = [UmsDocumentValidity]::Unknown

    ###########################################################################
    # Constructor
    ###########################################################################

    # Default constructor. Builds an instance from a UMS document passed as a
    # simple string.
    # Throws: same exceptions as ConstructDocument()
    UmsDocument([string] $DocumentString)
    {
        [EventLogger]::LogVerbose("Constructor was called without a source URI.")
        $this.ConstructDocument($DocumentString)
    }

    # Proxy to the main constructor. SourceUri is specified at construction
    # time.
    # Throws: same exceptions as ConstructDocument()
    UmsDocument([string] $DocumentString, [System.Uri] $SourceUri)
    {
        [EventLogger]::LogVerbose(
            "Constructor was called with the following source URI: {0}" `
            -f $SourceUri.AbsoluteUri)
        
        $this.ConstructDocument($DocumentString)
        $this.UpdateSourceUri($SourceUri)
    }

    ###########################################################################
    # Sub-constructors
    ###########################################################################

    # Actual constructor. Stored in another method as it is shared by several
    # constructor overloadings.
    # Throws:
    #   - [UDParseFailureException] if the document cannot be parsed.
    #   - [UDBadRootNamespaceException] if the document element belongs to an
    #       unsupported XML namespace.
    #   - [UDBadbindingNamespaceException] if the binding element belongs to an
    #       unsupported XML namespace.
    [void] ConstructDocument([string] $DocumentString)
    {
        [EventLogger]::LogVerbose(
            "Beginning to construct the UmsDocument instance.")

        # Set default validity and SourceUri status
        $this.Validity = [UmsDocumentValidity]::Unknown
        $this.UpdateSourceUriStatus()

        # Try to instantiate the XML document.
        [EventLogger]::LogVerbose("Parsing the XML document.")
        try
        {
            $this.XmlDocument = [System.Xml.XmlDocument] ($DocumentString)
        }
        catch [System.Xml.XmlException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UDParseFailureException]::New()
        }

        # Construct root element properties
        [EventLogger]::LogVerbose("Initializing root element properties.")
        try
        {
            $this.ConstructRootElementProperties()
        }
        catch [UDBadRootNamespaceException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Construct binding element properties
        [EventLogger]::LogVerbose("Initializing binding element properties.")
        try
        {
            $this.ConstructBindingElementProperties()
        }
        catch [UDBadBindingNamespaceException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Elect the main element and init its properties
        [EventLogger]::LogVerbose("Electing the main element.")
        $this.ConstructMainElementProperties()

        # Store the URI to the schema file
        [EventLogger]::LogVerbose("Resolving schema URI.")
        try
        {
            $this.SchemaFileUri = [System.Uri] (
                [ConfigurationStore]::GetSchemaItem($this.RootSchema).Uri)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UDBadRootNamespaceException]::New($this.RootNamespace)
        }
    }

    # Sets up all properties related to the binding element.
    # Throws:
    #   - [UDBadBindingNamespaceException] if the binding namespace is unknown.
    [void] ConstructBindingElementProperties()
    {
        # Set binding-related properties
        if (
            ($this.RootNamespace -eq ([UmsDocument]::NamespaceUri.Base)) -and
            ($this.RootLocalName -eq "file"))
        {
            $this.BindingDocument = $true
            $this.BindingElement = $this.XmlDocument.DocumentElement.FirstChild
            $this.BindingLocalName = $this.BindingElement.LocalName
            $this.BindingNamespace = $this.BindingElement.NamespaceURI
            $this.BindingName = $this.BindingElement.Name
        }
        else
        {
            $this.BindingDocument = $false
            return
        }

        # Extract the namespace id of the binding element
        try
        {
            $this.BindingSchema = (
                [ConfigurationStore]::GetSchemaItem("") | Where-Object {
                    $_.Namespace -eq $this.BindingNamespace }).Id
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UDBadBindingNamespaceException]::New($this.BindingNamespace)
        }
    }

    # Elects the main element and updates all related properties.
    # Does not throw any exception.
    [void] ConstructMainElementProperties()
    {
        if ($this.BindingDocument)
        {
            # Main element is the binding element
            $this.MainElement = $this.BindingElement
            $this.MainLocalName = $this.BindingLocalName
            $this.MainNamespace = $this.BindingNamespace
            $this.MainName = $this.BindingName
            $this.MainSchema = $this.BindingSchema
        }
        else
        {
            # Main element is the document element
            $this.MainElement = $this.RootElement
            $this.MainLocalName = $this.RootLocalName
            $this.MainNamespace = $this.RootNamespace
            $this.MainName = $this.RootName
            $this.MainSchema = $this.RootSchema
        }
    }

    # Sets up all properties related to the root element.
    # Throws:
    #   - [UDBadRootNamespaceException] if the binding namespace is unknown.
    [void] ConstructRootElementProperties()
    {
       # Set properties related to the document element
       $this.RootElement = $this.XmlDocument.DocumentElement
       $this.RootName = $this.RootElement.Name
       $this.RootNamespace = $this.RootElement.NamespaceURI
       $this.RootLocalName = $this.RootElement.LocalName

       # Extract the namespace id of the root element
       try
       {
           $this.RootSchema = (
               [ConfigurationStore]::GetSchemaItem("") | Where-Object {
                   $_.Namespace -eq $this.RootNamespace }).Id
       }
       catch [ConfigurationStoreException]
       {
        [EventLogger]::LogException($_.Exception)
           throw [UDBadRootNamespaceException]::New($this.RootNamespace)
       }
    }

    ###########################################################################
    # Methods dealing with source URI update
    ###########################################################################

    # Updates the value of the SourceUri property.
    # Throws:
    #   - [UDDuplicateSourceUriUpdateException] if the value of the SourceUri
    #       property was already update before, which is an unsupported
    #       scenario.
    [void] UpdateSourceUri([System.Uri] $Uri)
    {
        if ($this.SourceUri -eq $null)
        {
            $this.SourceUri = $Uri
            $this.UpdateSourceUriStatus()
        }
        else
        {
            throw [UDDuplicateSourceUriUpdateException]::New()
        }
    }

    # Updates the value of the SourceUriStatus property.
    # Throws no exception at all.
    [void] UpdateSourceUriStatus()
    {
        if ($this.SourceUri -eq $null)
        {
            $this.SourceUriStatus = [UmsDocumentSourceUriStatus]::Absent
        }
        else
        {
            $this.SourceUriStatus = [UmsDocumentSourceUriStatus]::Present
        }
    }

    ###########################################################################
    # Document validation
    ###########################################################################

    # Validates the document against a UMS schema, then updates the $Validity
    # property according to the result of the validation.
    # Throws:
    #   - [UDValidationFailureException] if the document cannot be validated.
    [void] Validate()
    {
        # Initialize a validator instance
        [RelaxNgValidator] $_validator = $null
        try
        {
            $_validator = [RelaxNgValidator]::New(
                $this.SchemaFileUri.LocalPath)
        }
        catch [RelaxNgValidatorException]
        {
            Write-Host -Message $_.Exception.MainMessage
            throw [UDValidationFailureException]::New()
        }

        # Get a handle to a temporary file
        [System.IO.FileInfo] $_tempFile = $null
        try
        {
            $_tempFile = New-TemporaryFile -ErrorAction Stop
        }
        # Not sure this is the right exception type.
        # Documentation is missing for PS exceptions.
        catch [System.Exception]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UDValidationFailureException]::New()
        }

        # Store the document into the temporary file
        try
        {
            $this.XmlDocument.Save($_tempFile)
        }
        catch [System.Xml.XmlException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UDValidationFailureException]::New()
        }

        # Validate the file
        [bool] $_isValid = $null
        try
        {
            $_isValid = $_validator.Validate($_tempFile.FullName)
        }
        catch [RelaxNgValidatorException]
        {
            Write-Host -Message $_.Exception.MainMessage
            throw [UDValidationFailureException]::New()
        }
        finally
        {
            # Remove the temporary file
            Remove-Item -Force -Path $_tempFile
        }

        # Update validation status
        if ($_isValid)
        {
            $this.Validity = [UmsDocumentValidity]::Valid
        }
        else
        {
            $this.Validity = [UmsDocumentValidity]::Invalid
        }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Return the document as a XML string.
    # This method does not throw any exception.
    [string] ToXmlString()
    {
        return $this.XmlDocument.OuterXml
    }

    # Return the string representation of the document.
    [string] ToString()
    {
        if ($this.SourceUriStatus -eq ([UmsDocumentSourceUriStatus]::Present))
        {
            return $this.SourceURI.AbsoluteUri
        }

        return "Anonymous document"
    }
}

###############################################################################
#   Enum UmsDocumentValidity
#==============================================================================
#
#   This enum defines the different states of validity of the Xml document.
#   The "unknown" value is default. It changes to Valid or Invalid after the
#   XML document was validated against a schema, which occurs on-demand.
#
###############################################################################

Enum UmsDocumentValidity
{
    Unknown
    Valid
    Invalid
}

###############################################################################
#   Enum UmsDocumentSourceUriStatus
#==============================================================================
#
#   This enum defines the different states of the SourceUri property. The
#   default value is "Absent", which means the SourceUri property has a
#   $null value. It changes to "Present" after the UpdateSourceUri() method
#   was called.
#
###############################################################################

Enum UmsDocumentSourceUriStatus
{
    Absent
    Present
}