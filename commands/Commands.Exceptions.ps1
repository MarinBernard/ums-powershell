###############################################################################
#   Exception class UmsPublicCommandException
#==============================================================================
#
#   Base type for all exceptions thrown by public commands.
#
###############################################################################

class UmsPublicCommandException : UmsException
{
    UmsPublicCommandException() : base() {}
}

###############################################################################
#   Exception class UmsPublicCommandException
#==============================================================================
#
#   Thrown on public command fatal failure.
#
###############################################################################

class UmsPublicCommandFailureException : UmsPublicCommandException
{
    UmsPublicCommandFailureException([string] $Command) : base()
    {
        $this.MainMessage = (
            "The '{0}' public command has failed."`
            -f $Command)
    }
}