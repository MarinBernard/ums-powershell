###############################################################################
#   Exception class VCCRendererFailureException
#==============================================================================
#
#   Thrown on subconverter method failure.
#
###############################################################################

class VCCRendererFailureException : ForeignMetadataConverterException
{
    VCCRendererFailureException([string] $SubconverterName) : base()
    {
        $this.MainMessage = (
            "The following subconverter method has failed: {0}" `
            -f $SubconverterName)
    }
}