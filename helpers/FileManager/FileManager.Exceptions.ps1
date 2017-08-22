###############################################################################
#   Exception class FileManagerException
#==============================================================================
#
#   Parent class for all exceptions thrown by the [FileManager] class.
#
###############################################################################

class FileManagerException : UmsException
{
    FileManagerException() : base()
    {}
}


    ###########################################################################
    #   Exception class FMGetFolderFailureException
    #==========================================================================
    #
    #   Thrown when the FileManager cannot return the path to a management
    #   folder.
    #
    ###########################################################################

    class FMGetFolderFailureException : FileManagerException
    {
        FMGetFolderFailureException([string] $Path, [string] $FolderType)
            : base()
        {
            $this.MainMessage = ($(
                "Unable to build the path to the '{0}' management folder " + `
                "for the following location: {1}") -f $FolderType,$Path)
        }
    }

    ###########################################################################
    #   Exception class FMTestManagementFailureException
    #==========================================================================
    #
    #   Thrown when the [ItemManger]::TestManagement() method cannot do its
    #   job.
    #
    ###########################################################################

    class FMTestManagementFailureException : FileManagerException
    {
        FMTestManagementFailureException([string] $Path) : base()
        {
            $this.MainMessage = ($(
                "Unable to check whether UMS management is enabled " + `
                "for the following location: {0}") -f $Path)
        }
    }

    ###########################################################################
    #   Exception class FMInconsistentStateException
    #==========================================================================
    #
    #   Parent exception for all exceptions dealing with inconsistencies in the
    #   management folder.
    #
    ###########################################################################

    class FMInconsistentStateException : FileManagerException
    {
        FMInconsistentStateException([string] $Path) : base()
        {
            $this.MainMessage = ($(
                "Inconsistencies were detected in the management folder " + `
                "linked to the following location: {0}") -f $Path)
        }
    }

        #######################################################################
        #   Exception class FMMissingCacheFolderException
        #======================================================================
        #
        #   Thrown when the cache folder is missing from the management folder.
        #
        #######################################################################

        class FMMissingCacheFolderException : FMInconsistentStateException
        {
            FMMissingCacheFolderException([string] $Path) : base($Path)
            {
                $this.MainMessage = ($(
                    "An inconsistency was detected in the management folder " + `
                    "linked to the following location, which lacks a cache " + `
                    "folder: {0}") -f $Path)
            }
        }

        #######################################################################
        #   Exception class FMMissingStaticFolderException
        #======================================================================
        #
        #   Thrown when the static folder is missing from the management
        #   folder.
        #
        #######################################################################

        class FMMissingStaticFolderException : FMInconsistentStateException
        {
            FMMissingStaticFolderException([string] $Path) : base($Path)
            {
                $this.MainMessage = ($(
                    "An inconsistency was detected in the management folder " + `
                    "linked to the following location, which lacks a static " + `
                    "folder: {0}") -f $Path)
            }
        }

    ###########################################################################
    #   Exception class FMDisableManagementFailureException
    #==========================================================================
    #
    #   Thrown when the [ItemManagement]::DisableManagement() method fails to
    #   disable UMS item management for a specific location.
    #
    ###########################################################################

    class FMDisableManagementFailureException : FileManagerException
    {
        FMDisableManagementFailureException([string] $Path) : base()
        {
            $this.MainMessage = ($(
                "Unable to disable UMS item management for " + `
                "the following location: {0}") -f $Path)
        }
    }

    ###########################################################################
    #   Exception class FMEnableManagementFailureException
    #==========================================================================
    #
    #   Thrown when the [ItemManagement]::EnableManagement() method fails to
    #   enable UMS item management for a specific location.
    #
    ###########################################################################

    class FMEnableManagementFailureException : FileManagerException
    {
        FMEnableManagementFailureException([string] $Path) : base()
        {
            $this.MainMessage = ($(
                "Unable to enable UMS item management for " + `
                "the following location: {0}") -f $Path)
        }
    }

    ###########################################################################
    #   Exception class FMHideManagementFolderFailureException
    #==========================================================================
    #
    #   Thrown when the [ItemManagement]::HideManagementFolder() method fails
    #   to hide the UMS item management folder for a specific location.
    #
    ###########################################################################

    class FMHideManagementFolderFailureException : FileManagerException
    {
        FMHideManagementFolderFailureException([string] $Path) : base()
        {
            $this.MainMessage = ($(
                "Unable to hide the UMS item management folder for " + `
                "the following location: {0}") -f $Path)
        }
    }

    ###########################################################################
    #   Exception class FMGetManagedFilesFailureException
    #==========================================================================
    #
    #   Thrown when the [ItemManagement]::GetManagedFiles() method encounters
    #   a fatal failure.
    #
    ###########################################################################

    class FMGetManagedFilesFailureException : FileManagerException
    {
        FMGetManagedFilesFailureException([System.IO.DirectoryInfo] $Path) : base()
        {
            $this.MainMessage = ($(
                "Unable list managed files for the following location: {0}") `
                -f $Path.FullName)
        }
    }

    ###########################################################################
    #   Exception class FMManagementNotEnabledException
    #==========================================================================
    #
    #   Thrown when an action requires UMS management to be enabled,
    #   but it is not.
    #
    ###########################################################################

    class FMManagementNotEnabledException : FileManagerException
    {
        FMManagementNotEnabledException([System.IO.DirectoryInfo] $Path) : base()
        {
            $this.MainMessage = ($(
                "Cannot continue as UMS filemanagement is disabled " + `
                "for the following location: {0}") -f $Path.FullName)
        }
    }

###############################################################################
#   Exception class UmsFileException
#==============================================================================
#
#   Parent class for all exceptions thrown by the [UmsFile] class.
#
###############################################################################

class UmsFileException : UmsException
{
    UmsFileException() : base() {}
}

    ###########################################################################
    #   Exception class UFFileNotFoundException
    #==========================================================================
    #
    #   Thrown when the [UmsFile] constructor cannot find the source UMS file.
    #
    ###########################################################################

    class UFFileNotFoundException : UmsFileException
    {
        UFFileNotFoundException([System.IO.FileInfo] $File) : base()
        {
            $this.MainMessage = ($(
                "Unable to create a new instance as the UMS file at the " + `
                "following location does not exist: {0}") -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFDocumentCreationFailureException
    #==========================================================================
    #
    #   Thrown when the [DocumentCache] class threw an error when the [UmsFile]
    #   constructor tried to retrieve a [UmsDocument] instance from the source
    #   UMS file.
    #
    ###########################################################################

    class UFDocumentCreationFailureException : UmsFileException
    {
        UFDocumentCreationFailureException([System.IO.FileInfo] $File) : base()
        {
            $this.MainMessage = ($(
                "Unable to obtain a UmsDocument instance from the UMS " + `
                "file at the following location: {0}") -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFUriCreationFailureException
    #==========================================================================
    #
    #   Thrown by the constructor when a path could not be parsed to a URI.
    #
    ###########################################################################

    class UFUriCreationFailureException : UmsFileException
    {
        UFUriCreationFailureException([string] $Location) : base()
        {
            $this.MainMessage = ($(
                "Unable to parse the following string to a URI: {0}") `
                -f $Location)
        }
    }

    ###########################################################################
    #   Exception class UFGetManagementFolderFailureException
    #==========================================================================
    #
    #   Inherits from the [UmsFileException], exception as [UmsManagedFile]
    #   inherits from [UmsFile].
    #
    #   Thrown when the [UmsManagedFile] constructor fails at retrieving
    #   references to management-related folders.
    #
    ###########################################################################

    class UFGetManagementFolderFailureException : UmsFileException
    {
        UFGetManagementFolderFailureException(
            [System.IO.FileInfo] $File,
            [string] $FolderType
        ) : base()
        {
            $this.MainMessage = ($(
                "Unable to get a the location of the {0} folder of the " + `
                "UMS file at the following location: {1}") `
                -f $FolderType,$File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFDeletionFailureException
    #==========================================================================
    #
    #   Thrown when the Delete() method cannot remove the UMS file from the
    #   disk.
    #
    ###########################################################################

    class UFDeletionFailureException : UmsFileException
    {
        UFDeletionFailureException([System.IO.FileInfo] $File) : base()
        {
            $this.MainMessage = ($(
                "Unable to remove the UMS file at the following location " + `
                "from the file system: {0}") `
                -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFRenameFailureException
    #==========================================================================
    #
    #   Thrown when the Rename() method failed at renaming a file.
    #
    ###########################################################################

    class UFRenameFailureException : UmsFileException
    {
        UFRenameFailureException(
            [System.IO.FileInfo] $File,
            [string] $Destination) : base()
        {
            $this.MainMessage = ($(
                "Unable to the file at the following location: {0}. " + `
                "Destination was: {1}") `
                -f $File.FullName,$Destination)
        }
    }

    ###########################################################################
    #   Exception class UFCardinalityUpdateFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsFile] constructor when the cardinality of the
    #   constructed instance cannot be updated.
    #
    ###########################################################################

    class UFCardinalityUpdateFailureException : UmsFileException
    {
        UFCardinalityUpdateFailureException([System.IO.FileInfo] $File)
            : base()
        {
            $this.MainMessage = ($(
                "Unable to determine the cardinality of the UMS file " + `
                "at the following location: {0}") `
                -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFContentFileUpdateFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsFile] constructor when the properties related to
    #   the instance's content file cannot be updated.
    #
    ###########################################################################

    class UFContentFileUpdateFailureException : UmsFileException
    {
        UFContentFileUpdateFailureException([System.IO.FileInfo] $File)
            : base()
        {
            $this.MainMessage = ($(
                "Unable to retrieve information about the content file of " + `
                "the UMS file at the following location: {0}") `
                -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFGetStaticDocumentFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsManagedFile]::GetStaticDocument() method when it is
    #   unable to return a UmsDocument instance from the static version of the
    #   UmsFile instance.
    #
    ###########################################################################

    class UFGetStaticDocumentFailureException : UmsFileException
    {
        UFGetStaticDocumentFailureException([System.Uri] $Uri) : base()
        {
            $this.MainMessage = ($(
                "Unable to return a UmsDocument from the static version " + `
                "of the UmsFile instance built from the following URI: {0}") `
                -f $Uri.AbsoluteUri)
        }
    }

    ###########################################################################
    #   Exception class UFGetCachedMetadataFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsManagedFile]::GetStaticDocument() method when it is
    #   unable to return a UmsDocument instance from the static version of the
    #   UmsFile instance.
    #
    ###########################################################################

    class UFGetCachedMetadataFailureException : UmsFileException
    {
        UFGetCachedMetadataFailureException([System.Uri] $Uri) : base()
        {
            $this.MainMessage = ($(
                "Unable to return a deserialized entity from the cached " + `
                "version of the UmsFile instance built from the following " + `
                "URI: {0}") `
                -f $Uri.AbsoluteUri)
        }
    }

    ###########################################################################
    #   Exception class UFCachedMetadataUpdateFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsManagedFile]::UpdateCachedMetadata() method when it
    #   fails to update the cached version of the file's metadata.
    #
    ###########################################################################

    class UFCachedMetadataUpdateFailureException : UmsFileException
    {
        UFCachedMetadataUpdateFailureException([System.Uri] $Uri) : base()
        {
            $this.MainMessage = ($(
                "Unable to update the cached version of the metadata of " + `
                "the UmsFile instance built from the following URI: {0} " + `
                "URI: {0}") `
                -f $Uri.AbsoluteUri)
        }
    }    

    ###########################################################################
    #   Exception class UFStaticVersionUpdateFailureException
    #==========================================================================
    #
    #   Thrown by the [UmsManagedFile]::UpdateStaticVersion() method when
    #   it encounters a fatal error.
    #
    ###########################################################################

    class UFStaticVersionUpdateFailureException : UmsFileException
    {
        UFStaticVersionUpdateFailureException([System.IO.FileInfo] $File)
            : base()
        {
            $this.MainMessage = ($(
                "Unable to update the static version of the UMS file at " + `
                "the following location: {0}") `
                -f $File.FullName)
        }
    }

    ###########################################################################
    #   Exception class UFInvalidStaticVersionException
    #==========================================================================
    #
    #   Thrown by the [UmsManagedFile] class when the static version of the
    #   file does not validate against the Relax NG schema.
    #
    ###########################################################################

    class UFInvalidStaticVersionException : UmsFileException
    {
        UFInvalidStaticVersionException([System.IO.FileInfo] $File)
            : base()
        {
            $this.MainMessage = ($(
                "The static version of the following UMS file does not " + `
                "validate against the Relax NG schema: {0}") `
                -f $File.FullName)
        }
    }