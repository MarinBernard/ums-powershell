###############################################################################
#   Exception class RelaxNgValidatorException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [RelaxNgValidator] class.
#
###############################################################################

class RelaxNgValidatorException : UmsException
{
    RelaxNgValidatorException() : base() {}
}

###############################################################################
#   Exception class RNVGetJrePathFailureException
#==============================================================================
#
#   Thrown by the static constructor when the path to the Java Runtime
#   Environment cannot be determined
#
###############################################################################

class RNVGetJrePathFailureException : RelaxNgValidatorException
{
    RNVGetJrePathFailureException() : base()
    {
        $this.MainMessage = (
            "The path to the Java Runtime Environment cannot be determined.")
    }
}

###############################################################################
#   Exception class RNVGetJingJarPathFailureException
#==============================================================================
#
#   Thrown by the static constructor when the path to the Jing Jar archive
#   cannot be determined.
#
###############################################################################

class RNVGetJingJarPathFailureException : RelaxNgValidatorException
{
    RNVGetJingJarPathFailureException() : base()
    {
        $this.MainMessage = (
            "The path to the Jing validator cannot be determined.")
    }
}

###############################################################################
#   Exception class RNVJreNotFoundException
#==============================================================================
#
#   Thrown by the static constructor when the Java Runtime Environment is not
#   present at the path specified.
#
###############################################################################

class RNVJreNotFoundException : RelaxNgValidatorException
{
    RNVJreNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The Java Runtime Environment is not present " + `
            "at the following location: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class RNVJingJarNotFoundException
#==============================================================================
#
#   Thrown by the static constructor when the Jing validator Jar file is not
#   present at the path specified.
#
###############################################################################

class RNVJingJarNotFoundException : RelaxNgValidatorException
{
    RNVJingJarNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The Jing validator Java archive is not present " + `
            "at the following location: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class RNVSchemaFileNotFoundException
#==============================================================================
#
#   Thrown by the constructor when the specified schema file does not exist.
#
###############################################################################

class RNVSchemaFileNotFoundException : RelaxNgValidatorException
{
    RNVSchemaFileNotFoundException([string] $Path) : base()
    {
        $this.MainMessage = ($(
            "The schema file at the following location " + `
            "does not exist: {0}.") -f $Path)
    }
}

###############################################################################
#   Exception class RNVValidationFailureException
#==============================================================================
#
#   Thrown by the Validate() method on validation failure.
#
###############################################################################

class RNVValidationFailureException : RelaxNgValidatorException
{
    RNVValidationFailureException([string] $ValidatedFilePath) : base()
    {
        $this.MainMessage = ($(
            "The validation process failed unexpectedly for the file " + `
            "at the following location: {0}.") -f $ValidatedFilePath)
    }
}