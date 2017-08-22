###############################################################################
#   Class RelaxNgValidator
#==============================================================================
#
#   This class offers a simple way to validate an XML document against a
#   Relax NG schema.
#
###############################################################################

class RelaxNgValidator
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Path to the Java Runtime Environment
    static [string] $PathToJre

    # Path to the Jing validator Java archive
    static [string] $PathToJingJar

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Reference to the schema file.
    [System.Uri] $SchemaUri

    ###########################################################################
    # Constructors
    ###########################################################################

    # Initializes static properties.
    # Throws:
    #   - [RNVGetJrePathFailureException] if the path to the Java Runtime
    #       Environment cannot be determined.
    #   - [RNVJreNotFoundException] if the JRE is not present at the path
    #       specified.
    #   - [RNVGetJingJarPathFailureException] if the path to the Jing validator
    #       Java archive cannot be determined.
    #   - [RNVJingJarNotFoundException] if the Jing validator is not present at
    #        the path specified.
    static RelaxNgValidator()
    {
        # Get the path to the JRE binary
        try
        {
            [RelaxNgValidator]::PathToJre = (
                [ConfigurationStore]::GetToolItem("JreBin").Path)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [RNVGetJrePathFailureException]::New()
        }

        # Test the path to the JRE binary
        if (-not (Test-Path -Path ([RelaxNgValidator]::PathToJre)))
        {
            throw [RNVJreNotFoundException]::New(
                [RelaxNgValidator]::PathToJre)
        }

        # Get the path to the Jing Jar archive
        try
        {
            [RelaxNgValidator]::PathToJingJar = (
                [ConfigurationStore]::GetToolItem("JingJar").Path)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [RNVGetJingJarPathFailureException]::New()
        }

        # Test the path to the Jing validator
        if (-not (Test-Path -Path ([RelaxNgValidator]::PathToJingJar)))
        {
            throw [RNVJingJarNotFoundException]::New(
                [RelaxNgValidator]::PathToJingJar)
        }        
    }

    # Default constructor. Requires a reference to the Relax NG schema file.
    # Throws [RNVSchemaFileNotFoundException] if the schema file does not exist
    RelaxNgValidator([System.IO.FileInfo] $SchemaFile)
    {
        # Verify whether the schema file exists
        if (-not $this.SchemaFile.Exists)
        {
            throw [RNVSchemaFileNotFoundException]::New(
                $this.SchemaFile.FullName)
        }

        # Store the reference to the schema file.
        $this.SchemaUri = [System.Uri]::New($SchemaFile.FullName)
    }

    # Default constructor. Requires a URI to a Relax NG schema file.
    RelaxNgValidator([System.Uri] $SchemaUri)
    {
        # Store the URI to the schema.
        $this.SchemaUri = $SchemaUri
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Validates a file against the schema. Returns $true if the file validates,
    # $false otherwise.
    # Throws [RNVValidationFailureException] if the validation process meets an
    # unrecoverable error.
    [bool] Validate([System.Uri] $Uri)
    {
        # Verbose prefix
        $VerbosePrefix = "[RelaxNgValidator]::Validate(): "

        # Build JingJar argument list
        $_arguments = @(
            "-jar", [RelaxNgValidator]::PathToJingJar,
            $this.SchemaUri.AbsoluteUri,
            $Uri.AbsoluteUri
        )

        # Verbose logging
        [EventLogger]::LogVerbose(
            "Invoking the Jing validator with invocation string: {0}" `
            -f $(([RelaxNgValidator]::PathToJre) + " " + $_arguments))
        
        # Invoke Jing validator
        [int] $_exitCode = $null
        try
        {
            & ([RelaxNgValidator]::PathToJre) $_arguments
            $_exitCode = $LASTEXITCODE
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [RNVValidationFailureException]::New($Uri.AbsoluteUri)
        }
        
        if ($_exitCode -eq 0)
            { return $true }
        else
            { return $false }
    }
}