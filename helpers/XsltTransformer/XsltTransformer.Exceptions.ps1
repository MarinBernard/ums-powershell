###############################################################################
#   Exception class XsltTransformerException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [XsltTransformer] class.
#
###############################################################################

class XsltTransformerException : UmsException
{
    XsltTransformerException() : base() {}
}

###############################################################################
#   Exception class XSLTTGetJrePathFailureException
#==============================================================================
#
#   Thrown by the static constructor when the path to the Java Runtime
#   Environment cannot be determined
#
###############################################################################

class XSLTTGetJrePathFailureException : XsltTransformerException
{
    XSLTTGetJrePathFailureException() : base()
    {
        $this.MainMessage = (
            "The path to the Java Runtime Environment cannot be determined.")
    }
}

###############################################################################
#   Exception class XSLTTGetSaxonJarPathFailureException
#==============================================================================
#
#   Thrown by the static constructor when the path to the Jing Jar archive
#   cannot be determined.
#
###############################################################################

class XSLTTGetSaxonJarPathFailureException : XsltTransformerException
{
    XSLTTGetSaxonJarPathFailureException() : base()
    {
        $this.MainMessage = (
            "The path to the Saxon transformer cannot be determined.")
    }
}

###############################################################################
#   Exception class XSLTTJreNotFoundException
#==============================================================================
#
#   Thrown by the static constructor when the Java Runtime Environment is not
#   present at the path specified.
#
###############################################################################

class XSLTTJreNotFoundException : XsltTransformerException
{
    XSLTTJreNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The Java Runtime Environment is not present " + `
            "at the following location: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class XSLTTSaxonJarNotFoundException
#==============================================================================
#
#   Thrown by the static constructor when the Jing validator Jar file is not
#   present at the path specified.
#
###############################################################################

class XSLTTSaxonJarNotFoundException : XsltTransformerException
{
    XSLTTSaxonJarNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The Saxon transformer Java archive is not present " + `
            "at the following location: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class XSLTTStylesheetFileNotFoundException
#==============================================================================
#
#   Thrown by the constructor when the specified stylesheet file cannot be
#   accessed.
#
###############################################################################

class XSLTTStylesheetFileNotFoundException : XsltTransformerException
{
    XSLTTStylesheetFileNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The stylesheet file at the following location " + `
            "does not exist: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class XSLTTTransformationFailureException
#==============================================================================
#
#   Thrown by the Transform() method on transformation failure.
#
###############################################################################

class XSLTTTransformationFailureException : XsltTransformerException
{
    XSLTTTransformationFailureException([string] $TransformedFilePath) : base()
    {
        $this.MainMessage = ($(
            "The transformation process failed unexpectedly for the file " + `
            "at the following location: {0}.") -f $TransformedFilePath)
    }
}