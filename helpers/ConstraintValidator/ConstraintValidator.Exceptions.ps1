###############################################################################
#   Exception class ConstraintValidatorException
#==============================================================================
#
#   Parent type for all exceptions thrown by the [ConstraintValidator] class.
#
###############################################################################

class ConstraintValidatorException : UmsException
{
    ConstraintValidatorException() : base() {}
}

###############################################################################
#   Exception class CVDocumentValidationFailureException
#==============================================================================
#
#   Thrown by the ValidateDocument() method on validation failure
#
###############################################################################

class CVDocumentValidationFailureException : ConstraintValidatorException
{
    CVDocumentValidationFailureException(
        [UmsDocument] $Document,
        [PSCustomObject] $Constraint,
        [string] $BadValue)
        : base()
    {
        $this.MainMessage = (
            "The following UMS document failed constraint validation: {0} " `
            -f $Document.SourceUri.AbsoluteUri)

        $this.SubMessages += ("Constraint id: {0}" -f $Constraint.Id)
        $this.SubMessages += ("Constraint value: {0}" -f $Constraint.Value)
        $this.SubMessages += ("Item value: {0}" -f $BadValue)
    }
}

###############################################################################
#   Exception class CVFileValidationFailureException
#==============================================================================
#
#   Thrown by the ValidateFile() method on validation failure
#
###############################################################################

class CVFileValidationFailureException : ConstraintValidatorException
{
    CVFileValidationFailureException(
        [UmsFile] $File,
        [PSCustomObject] $Constraint,
        [string] $BadValue)
        : base()
    {
        $this.MainMessage = (
            "The following UMS file failed constraint validation: {0} " `
            -f $File.File.FullName)

        $this.SubMessages += ("Constraint id: {0}" -f $Constraint.Id)
        $this.SubMessages += ("Constraint value: {0}" -f $Constraint.Value)
        $this.SubMessages += ("Item value: {0}" -f $BadValue)
    }
}