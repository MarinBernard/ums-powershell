function Update-VorbisComment
{
    <#
    .SYNOPSIS
    Converts UMS metadata to Vorbis Comment, then updates the embedded metadata in FLAC music files.
    
    .DESCRIPTION
    This command calls the ConvertTo-VorbisComment command to convert UMS metadata to Vorbis Comment, then updates the associated music file with the resulting metadata. This command requires the presence of the metaflac utility on the host system. Since it updates metadata within an audio linked file, this command requires instances of the UmsFile class as input objects.

    .PARAMETER File
    An instance of the UmsFile class, as returned by the Get-UmsFile or Get-UmsManagedFile commands. This file must have a Sidecar cardinality, and embed a binding UMS document which is compatible with the ConvertTo-VorbisComment command.

    .PARAMETER Source
    This parameters allows to select the source of UMS metadata. A 'raw' source will generate an entity tree from the main UMS document. A 'static' source will generate the same entity tree but from the static version of the UMS file, if available. A 'cache' source will use cached metadata, if available.

    .EXAMPLE
    Get-UmsManagedFile "track01.flac" | Update-VorbisComment
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [UmsFile] $File,

        [ValidateSet("Cache", "Static", "Raw")]
        [string] $Source = "Cache"
    )

    Begin
    {
        # Shortcut to messages
        $Messages = $ModuleStrings.Commands

        # Instantiate the constraint validator
        $Validator = [ConstraintValidator]::New(
            [ConfigurationStore]::GetHelperItem(
                "VorbisCommentUpdater").Constraints)

        # Instantiate the updater
        $Updater = [VorbisCommentUpdater]::New(
            [ConfigurationStore]::GetHelperItem(
                "VorbisCommentUpdater").Options)
    }

    Process
    {
        # Validate file constraints
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
            $_comments = ConvertTo-VorbisComment -File $File -Source $Source
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            return
        }
        
        # Update embedded Vorbis Comment
        [EventLogger]::LogVerbose("Invoking the Vorbis Comment updater.")
        try
        {
            $Updater.UpdateFile($File.ContentFile, $_comments)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            return
        }
    }
}