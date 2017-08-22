###############################################################################
#   Exception class UmsDocumentException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [UmsDocument] class.
#
###############################################################################

class UmsDocumentException : UmsException
{
    UmsDocumentException() : base() {}
}

###############################################################################
#   Exception class UDParseFailureException
#==============================================================================
#
#   Thrown by the [UmsDocument] constructor when the supplied document string
#   cannot be parsed.
#
###############################################################################

class UDParseFailureException : UmsDocumentException
{
    UDParseFailureException() : base()
    {
        $this.MainMessage =  (
            "The supplied document string cannot be parsed to XmlDocument.")
    }
}

###############################################################################
#   Exception class UDBadRootNamespaceException
#==============================================================================
#
#   Thrown by the [UmsDocument] constructor when the XML namespace of the
#   document element in unsupported.
#
###############################################################################

class UDBadRootNamespaceException : UmsDocumentException
{
    UDBadRootNamespaceException([string] $BadNamespace) : base()
    {
        $this.MainMessage =  ($(
            "The document element of the UMS document belongs to " + `
            "the following XML namespace, which is unsupported: {0}") `
            -f $BadNamespace)
    }
}

###############################################################################
#   Exception class UDBadBindingNamespaceException
#==============================================================================
#
#   Thrown by the [UmsDocument] constructor when the XML namespace of the
#   binding element in unsupported.
#
###############################################################################

class UDBadBindingNamespaceException : UmsDocumentException
{
    UDBadBindingNamespaceException([string] $BadNamespace) : base()
    {
        $this.MainMessage =  ($(
            "The binding element of the UMS document belongs to " + `
            "the following XML namespace, which is unsupported: {0}") `
            -f $BadNamespace)
    }
}

###############################################################################
#   Exception class UDValidationFailureException
#==============================================================================
#
#   Thrown by the [UmsDocument]::Validate() method if the document cannot be
#   validated.
#
###############################################################################

class UDValidationFailureException : UmsDocumentException
{
    UDValidationFailureException() : base()
    {
        $this.MainMessage = "Unable to validate the document."
    }
}

###############################################################################
#   Exception class UDDuplicateSourceUriUpdateException
#==============================================================================
#
#   Thrown by the [UmsDocument]::UpdateSourceUri() method if the value of the
#   SourceUri has previously been updated.
#
###############################################################################

class UDDuplicateSourceUriUpdateException : UmsDocumentException
{
    UDDuplicateSourceUriUpdateException() : base()
    {
        $this.MainMessage = (
            "The value of the SourceUri property has already been updated.")
    }
}