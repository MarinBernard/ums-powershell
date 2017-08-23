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

###############################################################################
#   Exception class AbstractClassInstantiationexception
#==============================================================================
#
#   Thrown when an abstract class is instantiated.
#
###############################################################################

class AbstractClassInstantiationexception : UmsException
{
    AbstractClassInstantiationexception([string] $ClassName) : base()
    {
        $this.MainMessage = (
            "Unable to instantiate the following abstract class: {0}" `
            -f $ClassName)
    }
}

###############################################################################
#   Exception class AbstractMethodCallexception
#==============================================================================
#
#   Thrown when an abstract method is invoked.
#
###############################################################################

class AbstractMethodCallexception : UmsException
{
    AbstractMethodCallexception(
        [string] $ClassName,
        [string] $MethodName)
    : base()
    {
        $this.MainMessage = ($(
            "Unable to call the '{0}' abstract method " + `
            "from the '{1}' abstract class.") `
            -f @($MethodName, $ClassName) )
    }
}