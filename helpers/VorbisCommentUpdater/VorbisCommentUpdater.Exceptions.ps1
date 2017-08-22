###############################################################################
#   Exception class VorbisCommentUpdaterException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [VorbisCommentUpdater]
#   class.
#
###############################################################################

class VorbisCommentUpdaterException : UmsException
{
    VorbisCommentUpdaterException() : base()
    {
        $this.MainMessage = "Vorbis Comment update has failed."
    }
}

###############################################################################
#   Exception class VCUConstructionFailureException
#==============================================================================
#
#   Thrown by the constructor on construction failure.
#
###############################################################################

class VCUConstructionFailureException : VorbisCommentUpdaterException
{
    VCUConstructionFailureException() : base()
    {
        $this.MainMessage = (
            "The constructor encountered a fatal failure.")
    }
}

###############################################################################
#   Exception class VCUMetaflacInvocationFailureException
#==============================================================================
#
#   Thrown on MetaFlac invocation failure or bad return code.
#
###############################################################################

class VCUMetaflacInvocationFailureException : VorbisCommentUpdaterException
{
    VCUMetaflacInvocationFailureException([string] $MetaflacOutput) : base()
    {
        $this.MainMessage = (
            "Metaflac invocation failure with the following output: {0}" `
            -f $MetaflacOutput)
    }
}