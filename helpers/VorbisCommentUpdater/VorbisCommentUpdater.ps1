###############################################################################
#   Class VorbisCommentUpdater
#==============================================================================
#
#   This helper class offers methods to update Vorbis Comment metadata within
#   files using the FLAC container.
#
###############################################################################

class VorbisCommentUpdater : ForeignMetadataUpdater
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # The path to the MetaFlac utility
    hidden [string] $PathToMetaflac

    # The extension of Vorbis Comment tag files, including the dot.
    hidden [string] $TagFileExtension

    ###########################################################################
    # Visible properties
    ###########################################################################

    # The set of pictures which will be embedded into the destination file.
    [PSCustomObject[]] $PictureList

    # The set of Vorbis Comment statements which will be embedded into the
    # destination file.
    [string[]] $VorbisCommentList

    ###########################################################################
    # Constructors
    ###########################################################################

    # Initializes options at first use.
    # Throws:
    #   - [FMUConstructionFailureException] when a fatal error is met.
    VorbisCommentUpdater([object[]] $Options) : base()
    {
        [EventLogger]::LogVerbose(
            "Beginning VorbisCommentUpdater instantiation.")

        # Update options
        foreach ($_option in $Options)
        {
            $this.SetOption($_option.ShortName, $_option.Value)
        }

        # Check whether all mandatory options are set
        $_mandatoryOptions = @("PathToMetaflac", "TagFileExtension")
        foreach ($_mandatoryOption in $_mandatoryOptions)
        {
            if (-not $this.$_mandatoryOption)
            {
                [EventLogger]::LogError(
                    "Mandatory option '{0}' is missing." `
                    -f $_mandatoryOption)
                throw [FMUConstructionFailureException]::New()
            }
        }
    }

    ###########################################################################
    # Option switchers
    ###########################################################################

    # Set an option to the specified value.
    # Throws nothing.
    [void] SetOption([string] $Name, $Value)
    {
        [EventLogger]::LogVerbose(
            "Processing option '{0}' with value '{1}'." `
            -f @($Name, $Value))
        
        switch ($Name)
        {
            "PathToMetaflac"    { $this.PathToMetaflac = $Value }
            "TagFileExtension"  { $this.TagFileExtension = $Value }

            default
            {
                [EventLogger]::LogWarning(
                    "Unknown option '{0}' with value '{1}'." `
                    -f @($Name, $Value))
            }
        }
    }

    ###########################################################################
    # Metadata setters
    ###########################################################################

    # Adds one or several album pictures to the updater queue.
    [void] AddPicture([PSCustomObject[]] $Pictures)
    {
        $this.PictureList += $Pictures
    }

    # Adds one or several Vorbis Comment statements to the updater queue.
    [void] AddVorbisComment([string[]] $Statements)
    {
        $this.VorbisCommentList += $Statements
    }

    ###########################################################################
    # Concrete implementations of [ForeignMetadataUpdater] abstract methods
    ###########################################################################

    # Adds Vorbis Comment statements or album pictures to the updater instance.
    # Implements an abstract method from the [ForeignMetadataUpdater] class.
    # Parameters:
    #   - $Metadata is a collection of PSCustomObject built by a converter.
    # Throws:
    #   - [FMUAddMetadataFailureException] on failure.
    [void] AddMetadata([PSCustomObject[]] $Metadata)
    {
        try
        {
            foreach ($_metadatum in $Metadata)
            {
                if (Get-Member -InputObject $_metadatum -Name "VorbisComment")
                {
                    $this.AddVorbisComment($_metadatum.VorbisComment)
                }

                if (Get-Member -InputObject $_metadatum -Name "Pictures")
                {
                    $this.AddPicture($_metadatum.Pictures)
                }
            }
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMUAddMetadataFailureException]::New()
        }
    }

    # Returns a FileInfo reference to a tag file from a UMS file.
    # Implements an abstract method from the [ForeignMetadataUpdater] class.
    # Parameters:
    #   - $File is a UMS file with Sidecar cardinality.
    # Throws:
    #   - [FMUGetExternalVersionFileException] on failure.
    [System.IO.FileInfo] GetExternalVersionFile([UmsFile] $File)
    {
        [System.IO.FileInfo] $_tagFile = $null

        try
        {
            $_tagFile = $($File.ContentFile.FullName + $this.TagFileExtension)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMUGetExternalVersionFileException]::New($File.File)
        }

        [EventLogger]::LogVerbose(
            "Built tag file name: {0}" -f $_tagFile.FullName)

        return $_tagFile
    }

    # Updates Vorbis Comment metadata embedded within the specified audio file.
    # Implements an abstract method from the [ForeignMetadataUpdater] class.
    # Parameters:
    #   - $File is a UMS file with Sidecar cardinality.
    # Throws:
    #   - [System.IO.FileNotFoundException] if the file does not exist.
    #   - [FMUEmbeddedVersionUpdateException] on update failure.
    [void] UpdateEmbeddedVersion([UmsFile] $File)
    {
        [EventLogger]::LogVerbose($(
            "Request to update embedded Vorbis Comment metadata in the " + `
            "content file of the following UMS file: {0}") -f $File.FullName)
        
        # Check whether content file exist
        if (-not $File.ContentFile.Exists)
        {
            throw [System.IO.FileNotFoundException]::New(
                "The content file does not exist: {0}" `
                -f $File.ContentFile.FullName)
        }

        [EventLogger]::LogVerbose($(
            "Beginning to update embedded Vorbis Comment metadata in the " + `
            "following audio file: {0}") -f $File.ContentFile.FullName)

        [System.IO.FileInfo] $_temporaryFile = $null
        try
        {
            # Get a temporary file to store Vorbis Comment statements
            $_temporaryFile = New-TemporaryFile

            # Export Vorbis Comment statements to the temporary file.
            $this.WriteTagFile($_temporaryFile, $this.VorbisCommentList)
            
            # Remove previous metadata
            $this.RemoveAllMetadata($File)

            # Build the argument list for metaflac
            [string[]] $_argumentList = @()

            # Prevent UTF8 re-conversion, which corrupts read data
            $_argumentList += "--no-utf8-convert"

            # Name of the tag file storing Vorbis Comments
            $_argumentList += ("--import-tags-from=`"{0}`"" `
                -f $_temporaryFile.FullName)

            # List of pictures to embed
            foreach ($_picture in $this.PictureList)
            {
                $_specification = ("{0}|{1}|{2}|{3}|{4}" -f @(
                    $_picture.Type.Value__,
                    "",
                    $_picture.Description,
                    "",
                    $File.GetLinkedResource($_picture.Uri).FullName
                ))
                $_argumentList += ("--import-picture-from={0}" `
                -f $_specification)
            }

            # Name of the target FLAC file
            $_argumentList += $File.ContentFile.FullName

            # Invoke metaflac
            $this.InvokeMetaflac($_argumentList)
        }

        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMUEmbeddedVersionUpdateException]::new(
                $File.ContentFile.FullName)
        }

        finally
        {
            # Remove the temporary file
            Remove-Item `
                -Force `
                -Path $_temporaryFile.FullName `
                -ErrorAction "SilentlyContinue"
        }

        [EventLogger]::LogVerbose($(
            "Finished to update embedded Vorbis Comment metadata in " + `
            "the following audio file: {0}") -f $File.ContentFile.FullName)
    }

    # Writes a set of Vorbis Comment statements to an external file.
    # Implements an abstract method from the [ForeignMetadataUpdater] class.
    # Parameters:
    #   - $File is a UMS file with Sidecar cardinality.
    # Throws:
    #   - [FMUExternalVersionUpdateException] on write failure.
    [void] UpdateExternalVersion([UmsFile] $File)
    {
        [EventLogger]::LogVerbose($(
            "Beginning to update the external version of Vorbis Comment " + `
            "metadata for the following UMS file: {0}") -f $File.FullName)

        try
        {
            # Get the name of the external tag file
            $_externalFile = $this.GetExternalVersionFile($File)

            [EventLogger]::LogVerbose($(
                "Exporting {0} Vorbis Comment statements to the following " + `
                "external version file: {1}") `
                -f @($this.VorbisCommentList.Count, $_externalFile.FullName))

            # Write the file
            $this.WriteTagFile($_externalFile, $this.VorbisCommentList)            
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMUExternalVersionUpdateException]::New($File.File)
        }

        [EventLogger]::LogVerbose($(
            "Wrote {0} Vorbis Comment statements to the following " + `
            "external version file: {1}") `
            -f @($this.VorbisCommentList.Count, $_externalFile.FullName))
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Removes all metadata from a FLAC file.
    # Throws:
    #   - [FMUEmbeddedVersionUpdateException] on removal failure.
    [void] RemoveAllMetadata([UmsFile] $File)
    {
        try
        {
            # Build the argument list for metaflac
            [string[]] $_argumentList = @()

            # Remove all metadata
            $_argumentList += "--remove-all"

            # Name of the target FLAC file
            $_argumentList += $File.ContentFile.FullName

            # Invoke metaflac
            $this.InvokeMetaflac($_argumentList)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMUEmbeddedVersionUpdateException]::new(
                $File.ContentFile.FullName)
        }
    }

    # Invoke metaflac with the specified arguments.
    # Throws:
    #   - [VCUMetaflacInvocationFailureException] on invocation failure.
    [void] InvokeMetaflac([string[]] $Arguments)
    {
        [EventLogger]::LogVerbose("Metaflac invocation string: {0} {1}" `
            -f @($this.PathToMetaflac, ($Arguments -join(" "))))

        [int] $_exitCode = $null
        [string] $_output = $null
        try
        {
            $_output = & $this.PathToMetaflac $Arguments *>&1
            $_exitCode = $LASTEXITCODE
            [EventLogger]::LogVerbose("Metaflac output: {0}" -f $_output)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCUMetaflacInvocationFailureException]::New($_output)
        }

        # Check exit code
        if ($_exitCode -gt 0)
        {
            [EventLogger]::LogError("Metaflac exit code: {0}" `
                -f $_exitCode.ToString())
            throw [VCUMetaflacInvocationFailureException]::New($_output)
        }
    }

    # Write a set of Vorbis Comment statements to a tag file.
    # Throws:
    #   - [System.IO.IOException] on write failure.
    [void] WriteTagFile([System.IO.FileInfo] $File, [string[]] $Statements)
    {
        [EventLogger]::LogVerbose($(
            "Writing {0} Vorbis Comment statements to the following " + `
            "tag file: {1}") `
            -f @($Statements.Count, $File.FullName))

        try
        {
            # We use a .Net method as PS does not support UTF8 without BOM
            [IO.File]::WriteAllLines(
                $File.FullName,
                ($Statements -join([System.Environment]::NewLine)))             
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }
    }
}