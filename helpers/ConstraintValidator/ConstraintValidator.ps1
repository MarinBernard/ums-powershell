###############################################################################
#   Concrete class ConstraintValidator
#==============================================================================
#
#   This class is a toolset which can be used to validate a set of UmsItem
#   instances against a list of constraints. It is mainly used to validate
#   items passed to converter/stylesheet-related PS commands.
#
###############################################################################

class ConstraintValidator
{

    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    # A set of constraints. PsCustomObject is used because the constraint lists
    # are read from the configuration file.
    [PSCustomObject[]] $Constraints

    ###########################################################################
    # Constructors
    ###########################################################################

    # Main constructor. A set of constraints is needed at construction time.
    # This method cannot throw any custom exception
    ConstraintValidator([object[]] $Constraints)
    {
        $this.Constraints = $Constraints
    }

    ###########################################################################
    # Validators
    ###########################################################################

    # Validate a single UmsFile instance against the collection of constraints.
    # This method returns nothing: if no exception is throw, it must be assumed
    # that the supplied instance is valid.
    # Throws:
    #   - [CVDocumentValidationFailureException] on validation failure.
    [void] ValidateDocument([UmsDocument] $Document)
    {
        foreach ($_constraint in $this.Constraints)
        {
            # Ignore other types of constraint
            if ($_constraint.Id -notlike "document-*") { continue }

            switch ($_constraint.Id)
            {
                "document-binding-element-namespace"
                {
                    if ($Document.BindingNamespace -ne $_constraint.Value)
                    {
                        throw [CVDocumentValidationFailureException]::New(
                            $Document,
                            $_constraint,
                            $Document.BindingNamespace)
                    }
                }

                "document-binding-element-name"
                {
                    if ($Document.BindingLocalName -ne 
                        $_constraint.Value)
                    {
                        throw [CVDocumentValidationFailureException]::New(
                            $Document,
                            $_constraint,
                            $Document.BindingLocalName)
                    }
                }

                "document-document-element-namespace"
                {
                    if ($Document.RootNamespace -ne $_constraint.Value)
                    {
                        throw [CVDocumentValidationFailureException]::New(
                            $Document, $_constraint, $Document.RootNamespace)
                    }
                }

                "document-document-element-name"
                {
                    if ($Document.RootLocalName -ne $_constraint.Value)
                    {
                        throw [CVDocumentValidationFailureException]::New(
                            $Document, $_constraint, $Document.RootLocalName)
                    }
                }
            }
        }
    }

    # Validate a single UmsFile instance against the collection of constraints.
    # This method returns nothing: if no exception is throw, it must be assumed
    # that the supplied instance is valid.
    # Throws:
    #   - [CVFileValidationFailureException] on validation failure.
    #   - [CVDocumentValidationFailureException] on document validation failure
    [void] ValidateFile([UmsFile] $File)
    {
        # Try to validate the internal document instance
        try
        {
            $this.ValidateDocument($File.Document)
        }
        catch [CVDocumentValidationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Validate the file instance
        foreach ($_constraint in $this.Constraints)
        {
            # Ignore other types of constraint
            if ($_constraint.Id -notlike "file-*") { continue }

            switch ($_constraint.Id)
            {
                "file-cardinality"
                {
                    # Build the list of allowed cardinalities
                    [FileCardinality[]] $_allowedCardinalities = @()

                    switch ($_constraint.Value)
                    {
                        "Independent"
                        {
                            $_allowedCardinalities = @(
                                [FileCardinality]::Independent)
                        }

                        "Orphan"
                        {
                            $_allowedCardinalities = @(
                                [FileCardinality]::Orphan)
                        }

                        "Sidecar"
                        {
                            $_allowedCardinalities = @(
                                [FileCardinality]::Sidecar)
                        }

                        "SidecarOrOrphan"
                        {
                            $_allowedCardinalities = @(
                                [FileCardinality]::Sidecar,
                                [FileCardinality]::Orphan)
                        }
                    }

                    # Check cardinality
                    if ($_allowedCardinalities -notcontains($File.Cardinality))
                    {
                        throw [CVFileValidationFailureException]::New(
                            $File, $_constraint, $File.Cardinality)
                    }
                }

                "file-static-version-status"
                {
                    # Build the list of allowed statuses
                    [FileVersionStatus[]] $_allowedVersionStatuses = @()
                    
                    switch ($_constraint.Value)
                    {
                        "CurrentOrExpired"
                        {
                            $_allowedVersionStatuses = @(
                            [FileVersionStatus]::Current,
                            [FileVersionStatus]::Expired)
                        }
                    }

                    # Check cardinality
                    if ($_allowedVersionStatuses -notcontains($File.StaticVersion))
                    {
                        throw [CVFileValidationFailureException]::New(
                            $File, $_constraint, $File.StaticVersion)
                    }
                }
            }
        }
    }
}