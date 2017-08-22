###############################################################################
#   Class VorbisCommentUpdater
#==============================================================================
#
#   This helper class offers methods to update Vorbis Comment metadata within
#   files using the FLAC container.
#
###############################################################################

class VorbisCommentUpdater
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # The path to the MetaFlac utility
    hidden [string] $PathToMetaflac

    # Whether all Vorbis Comments are removed before adding new ones
    hidden [bool] $RemoveAllComments

    # Whether tag files must be kept on the disk.
    hidden [bool] $PersistTagFiles

    # The extension of Vorbis Comment tag files, including the dot.
    hidden [string] $TagFileExtension

    ###########################################################################
    # Visible properties
    ###########################################################################

    ###########################################################################
    # Constructors
    ###########################################################################

    # Initializes options at first use.
    # Throws:
    #   - [VCUConstructionFailureException] when a fatal error is met.
    VorbisCommentUpdater([object[]] $Options)
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
                throw [VCUConstructionFailureException]::New()
            }
        }
    }

    ###########################################################################
    # Option switchers
    ###########################################################################

    # Set an option to the specified value.
    # Throws nothing.
    SetOption([string] $Name, $Value)
    {
        [EventLogger]::LogVerbose(
            "Processing option '{0}' with value '{1}'." `
            -f @($Name, $Value))
        
        switch ($Name)
        {
            "RemoveAllComments" { $this.RemoveAllComments = $Value }
            "PathToMetaflac"    { $this.PathToMetaflac = $Value }
            "TagFileExtension"  { $this.TagFileExtension = $Value }
            "TagFilePersist"    { $this.PersistTagFiles = $Value }

            default
            {
                [EventLogger]::LogWarning(
                    "Unknown option '{0}' with value '{1}'." `
                    -f @($Name, $Value))
            }
        }
    }

    ###########################################################################
    # API
    ###########################################################################

    # Updates Vorbis Comments embedded within the specified file.
    # Throws:
    #   - [System.IO.FileNotFoundException] if the file does not exist.
    #   - [VCUMetaflacInvocationFailureException] on metaflac invocation
    #       failure
    UpdateFile([System.IO.FileInfo] $File, [string[]] $VorbisComments)
    {
        [EventLogger]::LogVerbose(
            "Beginning the update of {0} embedded Vorbis Comments." `
            -f $VorbisComments.Count)

        # Halt here if the target file does not exist.
        if (-not $File.Exists)
        {
            throw [System.IO.FileNotFoundException]
        }

        # Build the name of the tag file
        [System.IO.FileInfo] $_tagFile = $null
        if ($this.PersistTagFiles)
        {
            # If persistence is enabled, we use the same base name
            # as the target audio file.
            $_tagFile = $($File.FullName + $this.TagFileExtension)
        }
        else
        {
            # Else, we try to use a temporary file.
            try
            {
                $_tagFile = New-TemporaryFile
            }
            catch
            {
                [EventLogger]::LogException($_.Exception)
                [EventLogger]::LogError("Unable to acquire a temporary file.")
                throw $_.Exception
            }
        }
        [EventLogger]::LogVerbose(
            "Built tag file name: {0}" -f $_tagFile.FullName)

        # Export the tags into the tagfile
        [EventLogger]::LogVerbose("Exporting Vorbis Comments to the tag file.")
        try
        {
            # We use a .Net method as PS does not support UTF8 without BOM
            [IO.File]::WriteAllLines(
                $_tagFile.FullName,
                ($VorbisComments -join([System.Environment]::NewLine)))             
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError(
                "Unable to write Vorbis Comments to the tag file.")

            # Remove the tag file, if needed
            if (-not $this.PersistTagFiles)
            {
                Remove-Item `
                -Force `
                -Path $_tagFile.FullName `
                -ErrorAction "SilentlyContinue"
            }

            # Proxify the exception
            throw $_.Exception
        }
        
        # Build the argument list for metaflac
        [string[]] $_argumentList = @()
        # Remove all tags if the option is set
        if ($this.RemoveAllComments){ $_argumentList += "--remove-all-tags" }
        # Prevent UTF8 conversion, as our file is already in the good encoding. 
        $_argumentList += "--no-utf8-convert"
        # Name of the tag file storing Vorbis Comments
        $_argumentList += ("--import-tags-from=`"{0}`"" -f $_tagFile.FullName)
        # Name of the target FLAC file
        $_argumentList += $File.FullName
        
        # Invoke metaflac
        [EventLogger]::LogVerbose("Metaflac invocation string: {0} {1}" `
            -f @($this.PathToMetaflac, ($_argumentList -join(" "))))
        [int] $_exitCode = $null
        [string] $_output = $null
        try
        {
            $_output = & $this.PathToMetaflac $_argumentList *>&1
            $_exitCode = $LASTEXITCODE
            [EventLogger]::LogVerbose("Metaflac output: {0}" -f $_output)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [VCUMetaflacInvocationFailureException]::New($_output)
        }
        finally
        {
            # Remove the tag file, if needed
            if (-not $this.PersistTagFiles)
            {
                Remove-Item `
                -Force `
                -Path $_tagFile.FullName `
                -ErrorAction "SilentlyContinue"
            }
        }

        # Check exit code
        if ($_exitCode -gt 0)
        {
            [EventLogger]::LogError("Metaflac exit code: {0}" `
                -f $_exitCode.ToString())
            throw [VCUMetaflacInvocationFailureException]::New($_output)
        }
    }
}