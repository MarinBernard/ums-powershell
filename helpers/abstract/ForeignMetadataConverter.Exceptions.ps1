###############################################################################
#   Exception class ForeignMetadataConverterException
#==============================================================================
#
#   Parent type for all exceptions thrown by foreign metadata converters.
#
###############################################################################

class ForeignMetadataConverterException : UmsException
{
    ForeignMetadataConverterException() : base()
    {
        $this.MainMessage = "Metadata conversion has failed."
    }
}

###############################################################################
#   Exception class FMCConversionFailureException
#==============================================================================
#
#   Thrown by the Convert() method on conversion failure.
#
###############################################################################

class FMCConversionFailureException : ForeignMetadataConverterException
{
    FMCConversionFailureException() : base()
    {
        $this.MainMessage = "Metadata conversion to has failed."
    }
}