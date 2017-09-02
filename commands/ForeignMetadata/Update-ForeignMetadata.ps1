function Update-ForeignMetadata
{
    <#
    .SYNOPSIS
    Updates the external and/or embedded versions of foreign metadata.
    
    .DESCRIPTION
    This command converts UMS metadata to a foreign metadata format with the ConvertTo-ForeignMetadata command, then updates the external and/or embedded versions of those metadata. This command requires a UMS file as an input object, either managed or not. The UMS file must have a Sidecar cardinality, as a content file is required for the update to succeed.
    This command is able to update both external and embedded versions of a set of foreign metadata. The external version is what is usually called a 'tag file': this is a regular file which contains foreign metadata, usually stored as a plain-text or XML document. For instance, Kodi NFO files and Adobe XMP sidecar files are external metadata files. The embedded version is a copy of the same set of metadata which is stored within the content file itself. ID3 tags or Vorbis Comment are two examples of embedded metadata specifications.
    As of now, this command is only able to update Vorbis Comment metadata, both external and embedded (FLAC only).

    .PARAMETER File
    An instance of the UmsFile class, as returned by the Get-UmsFile or Get-UmsManagedFile commands. This file must have a Sidecar cardinality. The embedded UMS document must validate all the constraints of the target converter.

    .PARAMETER Source
    This parameters allows to select the source of UMS metadata. A 'raw' source will generate an entity tree from the main UMS document. A 'static' source will generate the same entity tree but from the static version of the UMS file, if available. A 'cache' source will use cached metadata, if available. Default is to use cached metadata.

    .PARAMETER Format
    The foreign metadata format to convert source UMS metadata into. As of now, VorbisComment is the only format supported.

    .PARAMETER Version
    The target of the update. This parameter accepts one of the following values: 'External' to update the external version, 'Embedded' to update the embedded version, 'All' to update both versions. Default value is to update both versions. Note that some converter do not support both versions.

    .EXAMPLE
    Get-UmsManagedFile "track01.flac" | Update-ForeignMetadata -Source "Raw" -Format "VorbisComment" -Version "External"
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

        [ValidateSet("Cache", "Static", "Raw")]
        [string] $Source = "Cache",

        [Parameter(Mandatory=$true)]
        [ValidateSet("VorbisComment")]
        [string] $Format,

        [ValidateSet("All", "Embedded", "External")]
        [string] $Version = "All"      
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands

        [ConstraintValidator] $Validator = $null
        [ForeignMetadataUpdater] $Updater = $null

        switch ($Format)
        {
            "VorbisComment"
            {
                try
                {
                    # Instantiate the constraint validator
                    $Validator = [ConstraintValidator]::New(
                        [ConfigurationStore]::GetHelperItem(
                            "VorbisCommentUpdater").Constraints)

                    # Instantiate the updates
                    $Updater = [VorbisCommentUpdater]::New(
                        [ConfigurationStore]::GetHelperItem(
                            "VorbisCommentUpdater").Options)
                }
                catch
                {
                    [EventLogger]::LogException($_.Exception)
                    throw [UmsPublicCommandFailureException]::(
                        "Update-ForeignMetadata")
                }
            }

            default
            {
                [EventLogger]::LogError(
                    $Messages.UnsupportedMetadataFormat)                
                throw [UmsPublicCommandFailureException]::(
                    "Update-ForeignMetadata")
            }
        }
    }

    Process
    {
        # Validate converter constraints
        try
        {
            $Validator.ValidateFile($File)
        }
        catch
        {
            # Validation failure
            [EventLogger]::LogException($_.Exception)
            [EventLogger]::LogError($Messages.ConstraintValidationFailure)
            return
        }

        # Try metadata conversion
        # Tags:
        #   - PublicCommandInvocation
        [string[]] $_comments = $null
        try
        {
            $_comments = ConvertTo-ForeignMetadata `
                -Format $Format `
                -File $File `
                -Source $Source
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            return
        }

        # Register Vorbis Comment statements
        $Updater.AddVorbisComment($_comments)
        
        # Update external version
        if (@("All", "External") -contains $Version)
        {
            [EventLogger]::LogVerbose("Invoking external version update.")
            try
            {
                $Updater.UpdateExternalVersion($File)
            }
            catch
            {
                [EventLogger]::LogException($_.Exception)
                return
            }
        }

        # Update embedded version
        if (@("All", "Embedded") -contains $Version)
        {
            [EventLogger]::LogVerbose("Invoking embedded version update.")
            try
            {
                $Updater.UpdateEmbeddedVersion($File)
            }
            catch
            {
                [EventLogger]::LogException($_.Exception)
                return
            }
        }
    }
}