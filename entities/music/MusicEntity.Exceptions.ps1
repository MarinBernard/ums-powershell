###############################################################################
#   Exception class UmsMusicEntityException
#==============================================================================
#
#   Base type for all exceptions thrown by music UMS entities.
#
###############################################################################

class UmsMusicEntityException : UmsEntityException
{
    UmsMusicEntityException() : base() {}
}

###############################################################################
#   Exception class UMENullSPathResultException
#==============================================================================
#
#   Thrown when a segment in a spath expression returns no results.
#
###############################################################################

class UMENullSPathResultException : UmsMusicEntityException
{
    UMENullSPathResultException([string] $Expression) : base()
    {
        $this.MainMessage =  (
            "The following SPath expression returned nothing: {0}" `
            -f $Expression)
    }
}