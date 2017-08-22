###############################################################################
#   Class XsltTransformer
#==============================================================================
#
#   This class offers a simple way to transform XML documents with a XSLT
#   stylesheet.
#
###############################################################################

class XsltTransformer
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Path to the Java Runtime Environment
    static [string] $PathToJre

    # Path to the Saxon transformer Java archive
    static [string] $PathToSaxonjar

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    # URI to the stylesheet.
    [System.Uri] $StylesheetUri

    ###########################################################################
    # Constructors
    ###########################################################################

    # Initializes static properties.
    # Throws:
    #   - [XSLTTGetJrePathFailureException] if the path to the Java Runtime
    #       Environment cannot be determined.
    #   - [XSLTTJreNotFoundException] if the JRE is not present at the path
    #       specified.
    #   - [XSLTTGetSaxonJarPathFailureException] if the path to the Saxon
    #       transformer Java archive cannot be determined.
    #   - [XSLTTSaxonJarNotFoundException] if the Saxon transformer is not
    #        present at the path specified.
    static XsltTransformer()
    {
        # Get the path to the JRE binary
        try
        {
            [XsltTransformer]::PathToJre = (
                [ConfigurationStore]::GetToolItem("JreBin").Path)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [XSLTTGetJrePathFailureException]::New()
        }

        # Test the path to the JRE binary
        if (-not (Test-Path -Path ([XsltTransformer]::PathToJre)))
        {
            throw [XSLTTJreNotFoundException]::New(
                [XsltTransformer]::PathToJre)
        }

        # Get the path to the Saxon Jar archive
        try
        {
            [XsltTransformer]::PathToSaxonJar = (
                [ConfigurationStore]::GetToolItem("SaxonJar").Path)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [XSLTTGetSaxonJarPathFailureException]::New()
        }

        # Test the path to the Saxon transformer
        if (-not (Test-Path -Path ([XsltTransformer]::PathToSaxonJar)))
        {
            throw [XSLTTSaxonJarNotFoundException]::New(
                [XsltTransformer]::PathToSaxonJar)
        }        
    }

    # Default constructor. Requires a URI to a XSLT stylesheet file.
    # Throws nothing.
    XsltTransformer([System.Uri] $StylesheetUri)
    {
        # Store the reference to the stylesheet file.
        $this.StylesheetUri = $StylesheetUri
    }

    # Default constructor. Requires a reference to a XSLT stylesheet file.
    # Throws:
    #   - [XSLTTStylesheetFileNotFoundException] if the stylesheet file
    #       does not exist
    XsltTransformer([System.IO.FileInfo] $StylesheetFile)
    {
        # Verify whether the stylesheet file exists
        if (-not $this.StylesheetFile.Exists)
        {
            throw [XSLTTStylesheetFileNotFoundException]::New(
                $this.StylesheetFile.FullName)
        }

        # Store a URI to the stylesheet file.
        $this.StylesheetUri = [System.Uri]::New($StylesheetFile.FullName)
    }

    ###########################################################################
    # Internal routines
    ###########################################################################

    # Invoke the Saxon transformer to transform the supplied document with the
    # configured stylesheet.
    # Throws:
    #   - [XSLTTTransformationFailureException] if the Saxon transformer meets
    #       an unrecoverable error.
    [void] InvokeTransformer(
        [System.Uri] $SourceFileUri,
        [System.IO.FileInfo] $Destination,
        [hashtable] $CustomArguments)
    {
        # Build SaxonJar argument list
        $_arguments = @(
            "-jar", [XsltTransformer]::PathToSaxonJar,
            $("-xsl:" + $this.StylesheetUri.AbsoluteUri),
            $("-s:" + $SourceFileUri.AbsoluteUri),
            $('-o:"' + $Destination.FullName + '"'),
            '-warnings:silent'
        )

        # Process custom arguments
        foreach ($_argumentName in $CustomArguments.Keys)
        {
            $_argumentValue = $CustomArguments[$_argumentName]
            $_arguments += "$_argumentName=$_argumentValue"
        }

        # Verbose logging
        [EventLogger]::LogVerbose(
            "Invoking the Saxon transformer with invocation string: {0}" `
            -f $(([XsltTransformer]::PathToJre) + " " + $_arguments))
        
        # Invoke Saxon transformer
        [int] $_exitCode = $null
        [string] $_output = $null
        try
        {
            $_output = & ([XsltTransformer]::PathToJre) $_arguments *>&1
            $_exitCode = $LASTEXITCODE
            [EventLogger]::LogVerbose("Saxon output: {0}" -f $_output)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [XSLTTTransformationFailureException]::New(
                $SourceFileUri.AbsoluteUri)
        }

        # Check exit code
        if ($_exitCode -gt 0)
        {
            [EventLogger]::LogError("Saxon exit code: {0}" `
                -f $_exitCode.ToString())
            throw [XSLTTTransformationFailureException]::New(
                $SourceFileUri.AbsoluteUri)
        }
    }

    ###########################################################################
    # API
    ###########################################################################

    # Runs XSLT transformation. This method is a wrapper around the
    # InvokeTransformer() method which uses a temporary file to store the
    # result of the transformation, thus avoiding to overwrite the destination
    # file on transformation failure.
    # Parameters:
    #   - $SourceFileUri is a URI object to the file to run the transform onto.
    #   - $Destination is a FileInfo reference to the file which stores the
    #       result of the transformation.
    # Throws:
    #   - [XSLTTTransformationFailureException] if the Saxon transformer meets
    #       an unrecoverable error.
    [void] Transform(
        [System.Uri] $SourceFileUri,
        [System.IO.FileInfo] $Destination,
        [hashtable] $CustomArguments)
    {

        # Get a temporary file
        [System.IO.FileInfo] $_temporaryFile = $null
        try
        {
            $_temporaryFile = New-TemporaryFile
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogVerbose("Unable to get a temporary file.")
            throw [XSLTTTransformationFailureException]::New(
                $SourceFileUri.AbsoluteUri)
        }

        # Try to run the transform
        try
        {
            $this.InvokeTransformer(
                $SourceFileUri, $_temporaryFile, $CustomArguments)
        }
        catch [XSLTTTransformationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            $_temporaryFile | Remove-Item -Force -ErrorAction "Continue"
            throw [XSLTTTransformationFailureException]::New(
                $SourceFileUri.AbsoluteUri)
        }

        # Promote temporary file to final file
        try
        {
            Copy-Item `
                -Path $_temporaryFile.FullName `
                -Destination $Destination.FullName `
                -Force `
                -ErrorAction "Stop"
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [XSLTTTransformationFailureException]::New(
                $SourceFileUri.AbsoluteUri)
        }
        finally
        {
            $_temporaryFile | Remove-Item -Force -ErrorAction "Continue"
        }
    }
}