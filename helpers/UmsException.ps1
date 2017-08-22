###############################################################################
#   Exception class UmsException
#==============================================================================
#
#   This is the base class for all UMS exceptions.
#
###############################################################################

class UmsException : System.Exception
{
    [string] $MainMessage
    [string[]] $SubMessages
    
    UmsException() : base() {}
}