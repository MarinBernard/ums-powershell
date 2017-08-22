###############################################################################
#   Exception class VorbisCommentConverterException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [VorbisCommentConverter]
#   class.
#
###############################################################################

class VorbisCommentConverterException : UmsException
{
    VorbisCommentConverterException() : base()
    {
        $this.MainMessage = "Metadata conversion has failed."
    }
}

###############################################################################
#   Exception class VCCBadDocumentElementNameException
#==============================================================================
#
#   Thrown by the [VorbisCommentConverter]::Convert() method when the document
#   element of the supplied XML document belongs to an unsupported namespace.
#
###############################################################################

class VCCBadDocumentElementNameException : VorbisCommentConverterException
{
    VCCBadDocumentElementNameException([string] $ElementName) : base()
    {
        $this.MainMessage = (
            "XML document element has an unsupported name: {0}" `
            -f $ElementName)
    }
}

###############################################################################
#   Exception class VCCBadDocumentElementNamespaceException
#==============================================================================
#
#   Thrown by the [VorbisCommentConverter]::Convert() method when the document
#   element of the supplied XML document belongs to an unsupported namespace.
#
###############################################################################

class VCCBadDocumentElementNamespaceException : VorbisCommentConverterException
{
    VCCBadDocumentElementNamespaceException([string] $ElementNamespace)
        : base()
    {
        $this.MainMessage = (
            "XML document element belongs to an unsupported namespace: {0}" `
            -f $ElementNamespace)
    }
}

###############################################################################
#   Exception class VCCConversionFailureException
#==============================================================================
#
#   Thrown by the [VorbisCommentConverter]::Convert() method on conversion
#   failure.
#
###############################################################################

class VCCConversionFailureException : VorbisCommentConverterException
{
    VCCConversionFailureException() : base()
    {
        $this.MainMessage = "Conversion to Vorbis Comment has failed."
    }
}

###############################################################################
#   Exception class VCCRendererFailureException
#==============================================================================
#
#   Thrown by a [VorbisCommentConverter] renderer on fatal failure.
#
###############################################################################

class VCCRendererFailureException : VorbisCommentConverterException
{
    VCCRendererFailureException([string] $SubConverterName) : base()
    {
        $this.MainMessage = (
            "The following renderer encountered a fatal failure." `
            -f $SubConverterName)
    }
}