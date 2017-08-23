###############################################################################
#   Exception class VCUMetaflacInvocationFailureException
#==============================================================================
#
#   Thrown on MetaFlac invocation failure or bad return code.
#
###############################################################################

class VCUMetaflacInvocationFailureException : ForeignMetadataUpdaterException
{
    VCUMetaflacInvocationFailureException([string] $MetaflacOutput) : base()
    {
        $this.MainMessage = (
            "Metaflac invocation failure with the following output: {0}" `
            -f $MetaflacOutput)
    }
}