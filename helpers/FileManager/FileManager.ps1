###############################################################################
#   Class FileManager
#==============================================================================
#
#   This class implements common routines realted to UMS file management.
#
###############################################################################

class FileManager
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether UMS item management folders should be hidden.
    static [bool] $HideManagementFolders = (
        [ConfigurationStore]::GetSystemItem("HideManagementFolder"))

    # The extension of UMS files
    static [string] $UmsFileExtension = (
            [ConfigurationStore]::GetSystemItem("UmsFileExtension"))

    ###########################################################################
    # Management enable/disable/update/test routines
    ###########################################################################

    # Disables UMS item management for the specified location.
    # Throws:
    #   - [FMDisableManagementFailureException] when an unrecoverable error is
    #       encountered.
    static [void] DisableManagement(
        [System.IO.DirectoryInfo] $Path, [bool] $Confirm)
    {
        $VerbosePrefix = "[FileManager]::DisableManagement(): "

        # Try to get a handle to the management folder
        [System.IO.DirectoryInfo] $_managementFolder = $null
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMDisableManagementFailureException]::New($Path)
        }

        # Test management folder existence. If the folder does not exist, there
        # is nothing to disable and we halt here.
        if (-not $_managementFolder.Exists) { return }

        # Try to remove the whole management directory
        [EventLogger]::LogVerbose(
            "Removing UMS management directory at location: {0}" `
            -f $_managementFolder.FullName)
        try
        {            
            Remove-Item `
                -Path $_managementFolder `
                -Recurse -Force -Confirm:$Confirm `
                -ErrorAction Stop
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMDisableManagementFailureException]::New($Path)
        }
    }

    # Enables UMS item management for the specified location.
    # Throws:
    #   - [FMEnableManagementFailureException] when an unrecoverable error is
    #       encountered.
    static [void] EnableManagement([System.IO.DirectoryInfo] $Path)
    {
        $VerbosePrefix = "[UmsFile]::EnableManagement(): "

        # Try to get a handle to the management folder
        [System.IO.DirectoryInfo] $_managementFolder = $null
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Test management folder existence. If the folder does exist, there
        # is nothing to enable and we stop here.
        if ($_managementFolder.Exists) { return }

        # Try to create the management folder
        [EventLogger]::LogVerbose(
            "Creating a UMS management directory at location: {0}" `
            -f $_managementFolder.FullName)        
        try
        {
            $_managementFolder = $_managementFolder.Create()
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Try to get the full path to the cache folder
        [System.IO.DirectoryInfo] $_cacheFolder = $null
        try
        {
            $_cacheFolder = [FileManager]::GetCacheFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Try to create the cache folder
        [EventLogger]::LogVerbose(
            "Creating a UMS management cache directory at location: {0}" `
            -f $_cacheFolder.FullName)        
        try
        {
            $_cacheFolder = $_cacheFolder.Create()
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Try to get the full path to the static folder
        [System.IO.DirectoryInfo] $_staticFolder = $null
        try
        {
            $_staticFolder = [FileManager]::GetStaticFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Try to create the management folder
        [EventLogger]::LogVerbose(
            "Creating a UMS management static directory at location: {0}" `
            -f $_staticFolder.FullName)        
        try
        {
            $_staticFolder = $_staticFolder.Create()
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMEnableManagementFailureException]::New($Path)
        }

        # Hide management folder is hidden folders are enabled
        if ([FileManager]::HideManagementFolders)
        {
            try
            {
                [FileManager]::HideManagementFolder($Path)
            }
            catch [FMHideManagementFolderFailureException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [FMEnableManagementFailureException]::New($Path)
            }
        }
    }

    # Checks whether UMS management is enabled for the specified location.
    # Returns $true if it is, $false otherwise.
    # Parameter:
    #   - $Path is a content directory.
    # Throws:
    #   - [FMTestManagementFailureException] if the method cannot do its job.
    #   - [FMMissingCacheFolderException] if the cache folder is missing.
    #   - [FMMissingStaticFolderException] if the static folder is missing.
    static [bool] TestManagement([System.IO.DirectoryInfo] $Path)
    {
        # Try to get a handle to the management folder
        [System.IO.DirectoryInfo] $_managementFolder = $null
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMTestManagementFailureException]::New($Path)
        }

        # Test management folder existence
        if (-not $_managementFolder.Exists){ return $false }

        # Try to get a handle to the cache folder
        [System.IO.DirectoryInfo] $_cacheFolder = $null
        try
        {
            $_cacheFolder = [FileManager]::GetCacheFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMTestManagementFailureException]::New($Path)
        }
        
        # Test cache folder existence. It should exist. If it does not, we
        # assume the management folder is inconsistent and throw an exception.
        if (-not $_cacheFolder.Exists)
        {
            throw [FMMissingCacheFolderException]::New($Path)
        }

        # Try to get a handle to the static folder
        [System.IO.DirectoryInfo] $_staticFolder = $null
        try
        {
            $_staticFolder = [FileManager]::GetStaticFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMTestManagementFailureException]::New($Path)
        }
        
        # Test static folder existence. It should exist. If it does not, we
        # assume the management folder is inconsistent and throw an exception.
        if (-not $_staticFolder.Exists)
        {
            throw [FMMissingStaticFolderException]::New($Path)
        }

        # If we land here, management is declared enabled and valid.
        return $true
    }

    ###########################################################################
    # Path-related routines
    ###########################################################################

    # Returns the path of the cache folder for the specified content folder.
    # Throws [FMGetFolderFailureException] if an unrecoverable error is met.
    static [System.IO.DirectoryInfo] GetCacheFolder(
        [System.IO.DirectoryInfo] $Path)
    {
        [System.IO.DirectoryInfo] $_managementFolder = $null
        [string] $_cacheFolderName = $null

        # Try to get the path to the management folder.
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetFolderFailureException]::New($Path, "cache")
        }        

        # Try to get the name of the cache folder from the configuration store
        try
        {
            $_cacheFolderName  = ([ConfigurationStore]::GetSystemItem(
                "UmsFolderNameCache").Value)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetFolderFailureException]::New($Path, "cache")
        }

        # We assume Join-Path will never throw an exception.
        return (
            [System.IO.DirectoryInfo] (Join-Path `
                -Path $_managementFolder.FullName `
                -ChildPath $_cacheFolderName))
    }

    # Returns the path of the content folder from a mamangement folder.
    # Throws [FMGetFolderFailureException] if an unrecoverable error is met.
    static [System.IO.DirectoryInfo] GetContentFolder(
        [System.IO.DirectoryInfo] $ManagementFolder)
    {
        # Content folder is always the parent folder.
        $_contentFolder = $ManagementFolder.Parent

        # If content folder is $null, let's throw an exception.
        if ($_contentFolder -eq $null)
        {
            throw [FMGetFolderFailureException]::New(
                $ManagementFolder, "content")
        }

        return $_contentFolder
    }

    # Returns the path of the mgmt folder for the specified content folder.
    # Parameters:
    #   - $Path is a content directory.
    # Throws [FMGetFolderFailureException] if an unrecoverable error is met.
    static [System.IO.DirectoryInfo] GetManagementFolder(
        [System.IO.DirectoryInfo] $Path)
    {
        # Log parameter value
        [EventLogger]::LogVerbose(
            "Building management folder path for content path: {0}" `
            -f $Path.FullName)
        
        [string] $_managementFolderName = $null
        try
        {
            $_managementFolderName  = (
                [ConfigurationStore]::GetSystemItem(
                    "UmsFolderNameMain").Value)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetFolderFailureException]::New($Path, "management")
        }        

        # We assume that Join-Path will never throw an exception.
        [System.IO.DirectoryInfo] $_folder = (
             Join-Path `
                -Path $Path.FullName `
                -ChildPath $_managementFolderName)

        # Log returned value
        [EventLogger]::LogVerbose(
            "Returned management folder path: {0}" `
            -f $_folder.FullName)
        
        # Return the reference
        return $_folder
    }

    # Returns the path of the static folder for the specified content folder.
    # Throws [FMGetFolderFailureException] if an unrecoverable error is met.
    static [System.IO.DirectoryInfo] GetStaticFolder(
        [System.IO.DirectoryInfo] $Path)
    {
        [System.IO.DirectoryInfo] $_managementFolder = $null
        [string] $_staticFolderName = $null

        # Try to get the path to the management folder.
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetFolderFailureException]::New($Path, "static")
        } 

        # Try to get the name of the cache folder from the configuration store
        try
        {
            $_staticFolderName  = ([ConfigurationStore]::GetSystemItem(
                "UmsFolderNameStatic").Value)
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetFolderFailureException]::New($Path, "static")
        }

        # We assume Join-Path will never throw an exception.
        return (
            [System.IO.DirectoryInfo] (Join-Path `
                -Path $_managementFolder.FullName `
                -ChildPath $_staticFolderName))
    }

    ###########################################################################
    # File-related routines
    ###########################################################################

    # Returns a collection of UmsManagedFile instances from a content path and
    # a filtering glob.
    # Parameters:
    #   - $Path is a management-enabled content path.
    #   - $Filter is a glob string.
    # Throws:
    #   - [FMGetManagedFilesFailureException] on fatal error.
    #   - [FMManagementNotEnabledException] is ums management is not enabled.
    static [UmsManagedFile[]] GetManagedFiles(
        [System.IO.DirectoryInfo] $Path,
        [string] $Filter)
    {
        # Test whether management is enabled.
        [bool] $_managementIsEnabled = $null
        try
        {
            $_managementIsEnabled = [FileManager]::TestManagement($Path)
        }
        catch [FMInconsistentStateException]
        {
            # Non-terminating
            [EventLogger]::LogWarning($_.Exception.MainMessage)
        }
        catch [FMTestManagementFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetManagedFilesFailureException]::New($Path)
        }

        # If management is disabled, we throw an exception.
        if (-not $_managementIsEnabled)
        {
            throw [FMManagementNotEnabledException]::New($Path)
        }

        # Get a reference to the management folder
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMGetManagedFilesFailureException]::New($Path)
        }
        
        # Gather the list of all UMS files in the management directory
        [System.IO.FileInfo[]] $_items = Get-ChildItem `
            -File `
            -Path $_managementFolder `
            -Filter $($Filter + [FileManager]::UmsFileExtension)

        [EventLogger]::LogDebug(
            "Management directory contains {0} UMS files." -f $_items.Count)
        
        # Create UmsManagedFile instances
        [EventLogger]::LogVerbose(
            "Beginning to build UmsManagedFile instances")

        # Build the return collection
        [UmsManagedFile[]] $_managedFiles = @()
        foreach ($_item in $_items)
        {
            [UmsManagedFile] $_managedFile = $null

            try
            {
                $_managedFile = [UmsManagedFile]::New($_item)
            }
            catch [UmsFileException]
            {
                [EventLogger]::LogError($_.Exception)
                [EventLogger]::LogWarning(
                    "Ignoring the following UMS file: {0}" -f $_item.FullName)
                continue
            }

            $_managedFiles += $_managedFile
        }

        [EventLogger]::LogVerbose(
            "Finished to build UmsManagedFile instances")

        return $_managedFiles
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Hides the UMS management folder for the specified location.
    # Throws [FMHideManagementFolderFailureException] on error.
    static [void] HideManagementFolder([System.IO.DirectoryInfo] $Path)
    {
        $VerbosePrefix = "[FileManager]::HideManagementFolder(): "

        # Try to get a handle to the management folder
        [System.IO.DirectoryInfo] $_managementFolder = $null
        try
        {
            $_managementFolder = [FileManager]::GetManagementFolder($Path)
        }
        catch [FMGetFolderFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMHideManagementFolderFailureException]::New($Path)
        }

        # Test management folder existence. It should exist. If it does not, we
        # throw an exception.
        if (-not $_managementFolder.Exists)
        {
            throw [FMHideManagementFolderFailureException]::New($Path)
        }

        # Try to hide the management folder
        [EventLogger]::LogVerbose(
            "Hiding the UMS management directory at location: {0}" `
            -f $_managementFolder.FullName)  
        try
        {
            $_managementFolder.Attributes = (
                $_managementFolder.Attributes -bor 
                ([System.IO.FileAttributes]::Hidden))
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [FMHideManagementFolderFailureException]::New($Path)
        }
    }
}

###############################################################################
#   Class UmsFile
#==============================================================================
#
#   This class describes an basic, unmanaged UMS file. A UMS file is the
#   internal representation of a UMS file. As a consequence, UMS items are
#   always instantiated from a file system object, either from a local file
#   system or from a network equivalent such as SMB, and cannot be created
#   from a URI.
#
#   Each UmsFile instance represents a file system file, and stores various
#   attributes such as:
#   - Attributes specific to the file itself, such as the file name, path, or
#       extension.
#   - A UmsDocument instance, which is the in-memory representation of the
#       XML document read from the UMS file.
#   - An optional UmsEntity instance, which is an in-memory, user-friendly
#       representation of the UMS metadata extracted from the UmsDocument.
#
###############################################################################

class UmsFile
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # A reference to the UmsDocument instance built from the file's content.
    hidden [UmsDocument] $Document

    # The URI of the schema file associated with the UMS document
    # (Proxified from the UmsDocument instance stored in $Document)
    hidden [System.Uri] $SchemaFileUri

    # Properties describing the file from which the item was instantiated.
    hidden [System.IO.FileInfo] $File   # Reference to the item source file
    hidden [System.Uri] $Uri            # URI to $File
    hidden [System.Uri] $DirectoryUri   # URI to $File.Directory

    # Reference to the content folder
    # For unmanaged UMS files, this is the same as the file's parent folder.
    hidden [System.IO.DirectoryInfo] $ContentFolder

    # Uri to the content folder
    hidden [System.Uri] $ContentFolderUri

    # Properties related to the content file (for sidecar items only)
    hidden [System.IO.FileInfo] $ContentFile
    hidden [System.Uri]         $ContentFileUri

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Name of the UMS item. This name is not the same as the file name, which
    # is stored in the $File.Name property. The name of a UMS item is
    # equivalent to the base name of its source file (i.e.: without the file
    # extension).
    [string] $Name

    # Cardinality of the UMS item: whether it is an independent, sidecar or
    # orphaned item. Value Unknown is set by default but should never make it
    # through the construction process.
    [FileCardinality] $Cardinality = [FileCardinality]::Unknown

    # Friendly-name of the XML schema linked to the XML namespace of the
    # document element. If the item cardinality is Sidecar/Orphan, the
    # value of this property is set to the friendly-name of the XML schema
    # of the binding element, instead of the document element.
    # The value of this property is proxified from the UmsDocument instance
    [string] $MainElementSchema

    # The full name of the main XML element of the document. If the item
    # includes a binding document, this property is set to the name of
    # the binding element. Otherwise, it is set to the name of the document
    # element.
    # The value of this property is proxified from the UmsDocument instance
    [string] $MainElementName

    # Validation status of the UMS item. Validation is CPU intensive, and does
    # not occur automatically.
    # The value of this property is proxified from the UmsDocument instance
    [UmsDocumentValidity] $Validity = [UmsDocumentValidity]::Unknown

    ###########################################################################
    # Constructors
    ###########################################################################

    # Constructs a new UmsItem instance from a reference to a file. The file
    # must exist and be a valid UMS document.
    # Throws:
    #   - [UFFileNotFoundException] if the supplied UMS file does not exist.
    #   - [UFUriCreationFailureException] if the full path to the source file
    #       or to the source directory cannot be transformed to a URI.
    #   - [UFDocumentCreationFailureException] if a UmsDocument instance cannot
    #       be created from the source file.
    #   - [UFContentFileUpdateFailureException] if the properties related to
    #       the instance's content file cannot be updated.
    #   - [UFCardinalityUpdateFailureException] on cardinality update failure.
    UmsFile([System.IO.FileInfo] $File)
    {
        # Unable to instantiate if the source UMS file does not exist.
        if (-not $File.Exists)
        {
            throw [UFFileNotFoundException]::New($File)
        }

        # Store a reference to the source file
        $this.File = $File

        # Create a URI to the source file
        try
        {
            $this.Uri = [System.Uri]::New($this.File.FullName)
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New(
                $this.File.FullName)
        }

        # Create a URI to the source directory
        try
        {
            $this.DirectoryUri = (
                [System.Uri]::New($this.File.Directory.FullName))
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New(
                $this.File.Directory.FullName)
        }

        # Try to obtain the UmsDocument instance
        try
        {
            $this.Document = [DocumentFactory]::GetDocument($this.Uri)
        }
        catch [DocumentFactoryException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFDocumentCreationFailureException]::New($this.File)
        }

        # Update public properties
        $this.Name = $this.File.BaseName

        # Update properties which are proxified from the UmsDocumentInstance
        $this.UpdateDocumentProperties()  

        # Initialize content folder properties
        # Content folder of a unmanaged file is the same as the file's itself.
        $this.ContentFolder = ($this.File.Directory)
        $this.ContentFolderUri = (
            [System.Uri]::New($this.ContentFolder.FullName))

        # Calling sub-constructor dedicated to content file info
        try
        {
            $this.UpdateContentFileInfo()
        }
        catch [UmsFileException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFContentFileUpdateFailureException]::New($File)
        }
       
        # Calling sub-constructor dedicated to cardinality info
        try
        {
            $this.UpdateCardinalityInfo()
        }
        catch [UmsFileException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFCardinalityUpdateFailureException]::New($File)
        }
    }

    # Update all properties related to the content file.
    # Throws:
    #   - [UFUriCreationFailureException] if a URI cannot be created.
    [void] UpdateContentFileInfo()
    {
        # We only proceed if the item includes a binding document.
        if ($this.Document.BindingDocument)
        {
            # Build a reference to the content file.
            $this.ContentFile = [System.IO.FileInfo] (
                Join-Path `
                    -Path $this.ContentFolder.FullName `
                    -ChildPath $this.File.BaseName)

            # Create a URI to the content file
            try
            {
                $this.ContentFileUri = [System.Uri]::New(
                    $this.ContentFile.FullName)
            }
            catch [System.SystemException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [UFUriCreationFailureException]::New($this.ContentFile)
            }
        }
    }

    # Sub-constructor for cardinality information
    # Does not throw any exception.
    [void] UpdateCardinalityInfo()
    {
        if ($this.Document.BindingDocument)
        {
            # Check item link status
            if ($this.ContentFile.Exists)
            {
                $this.Cardinality = [FileCardinality]::Sidecar
            }
            else
            {
                $this.Cardinality = [FileCardinality]::Orphan
            }
        }

        # Any item including a non-binding document is declared independent
        else
        {
            $this.Cardinality = [FileCardinality]::Independent
        }
    }

    ###########################################################################
    # CRUD operations
    ###########################################################################

    # Deletes the UMS file from the disk.
    # Throws:
    #   - [UFDeletionFailureException] on file deletion failure.
    [void] Delete()
    {
        try
        {
            $this.File.Delete()
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFDeletionFailureException]::New($this.File)
        }
    }

    # Deletes the UMS content file from the disk.
    # Throws:
    #   - [UFDeletionFailureException] on file deletion failure.
    [void] DeleteContentFile()
    {
        try
        {
            if ($this.ContentFile.Exists)
            {
                $this.ContentFile.Delete()
            }
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFDeletionFailureException]::New($this.ContentFile)
        }

        # Update cardinality after CF deletion
        $this.UpdateCardinalityInfo()
    }

    # Deletes the UMS file and its content file from the disk.
    # Throws:
    #   - [UFDeletionFailureException] on file deletion failure.
    [void] DeleteWithContentFile()
    {
        # Delete content file
        try
        {
            $this.DeleteContentFile()
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Delete UMS file
        try
        {
            $this.Delete()
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }
    }

    # Renames the UMS file and its content file, if any. The method returns
    # a new UmsFile instance.
    # Throws:
    #   - [UFRenameFailureException] on rename failure.
    [UmsFile] Rename([string] $NewName)
    {
        if ($this.ContentFile.Exists)
        {
            # Build destination file real name
            $_contentFileNewName = (
                Join-Path `
                    -Path $this.ContentFile.Directory.FullName `
                    -ChildPath $NewName)

            # Move content file, if any
            try
            {
                $this.ContentFile | Move-Item -Destination $_contentFileNewName
            }
            catch [System.IO.IOException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [UFRenameFailureException]::New(
                    $this.ContentFile, $_contentFileNewName)
            }
        }

        # Build UMS new real file name
        $_umsFileNewName = $($NewName + ([FileManager]::UmsFileExtension))
        $_umsFileNewFullName = (
            Join-Path `
                -Path $this.File.Directory.FullName `
                -ChildPath $_umsFileNewName)
        
        # Move UMS file
        try
        {
            $this.File | Move-Item -Destination $_umsFileNewFullName
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFRenameFailureException]::New($this.File, $_umsFileNewFullName)
        }

        # Return a new instance
        return [UmsFile]::New([System.IO.FileInfo] $_umsFileNewFullName)
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Updates all document properties which are proxified from the UmsDocument
    # instance.
    [void] UpdateDocumentProperties()
    {
        $this.SchemaFileUri = $this.Document.SchemaFileUri
        $this.Validity = $this.Document.Validity
        $this.MainElementSchema = $this.Document.MainSchema
        $this.MainElementName = $this.Document.MainName
    }

    # String representation
    [string] ToString()
    {
        return $this.Name
    } 
}

###############################################################################
#   Class UmsManagedFile
#==============================================================================
#
#   This class describes a managed UmsFile, i.e. a UmsFile which is stored
#   in a local dedicated folder, and eligible to metadata and static version
#   caching.
#
#   The class inherits the UmsFile parent class, and adds:
#   - Properties dealing with the managed path and the optional linked file
#   - Properties describing the cache file and metadata caching status.
#   - Properties describing the static file and static version status.
#
###############################################################################

class UmsManagedFile : UmsFile
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # References to folders involved in UMS management
    hidden [System.IO.DirectoryInfo] $CacheFolder
    hidden [System.IO.DirectoryInfo] $ManagementFolder
    hidden [System.IO.DirectoryInfo] $StaticFolder

    # URI to folders involved in UMS management
    hidden [System.Uri] $CacheFolderUri
    hidden [System.Uri] $ManagementFolderUri
    hidden [System.Uri] $StaticFolderUri

    # Properties related to the static version of the item
    hidden [System.IO.FileInfo] $StaticFile
    hidden [System.Uri]         $StaticFileUri

    # Properties related to the cached metadata of the item
    hidden [System.IO.FileInfo] $CacheFile
    hidden [System.Uri]         $CacheFileUri

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Status of the static version of the UMS item. This property is set to
    # Unknown by default but should always be updated by the constructor.
    [FileVersionStatus] $StaticVersion = [FileVersionStatus]::Unknown

    # Status of the cached version of the UMS item metadata. This property is
    # set to Unknown by default but should always be updated by the constructor
    [FileVersionStatus] $CachedVersion = [FileVersionStatus]::Unknown

    ###########################################################################
    # Constructors
    ###########################################################################

    # Default constructor.
    # Throws:
    #   - [UmsFileException] on construction failure.
    UmsManagedFile([System.IO.FileInfo] $FileInfo) : base($FileInfo)
    {
        # Content folder of a managed file is always its parent directory.
        $this.ContentFolder = ($this.File.Directory.Parent)
        $this.ContentFolderUri = (
            [System.Uri]::New($this.ContentFolder.FullName))

        # Update content file properties since content dir has changed
        $this.UpdateContentFileInfo()

        # Update cardinality since content file status has changed
        $this.UpdateCardinalityInfo()
        
        # Call the sub-constructor to initialize properties dealing with
        # subfolders dedicated to the management infrastructure.
        try
        {
            $this.InitManagementFolderProperties()
        }
        catch [UmsFileException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsFileException]::New()
        }
        
        # Calling sub-constructor dedicated to static file info
        try
        {
            $this.UpdateStaticFileInfo()
        }
        catch [UmsFileException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsFileException]::New()
        }
        
        # Calling sub-constructor dedicated to cache file info
        try
        {
            $this.UpdateCacheFileInfo()
        }
        catch [UmsFileException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UmsFileException]::New()
        }
    }

    # Sub-constructor for properties describing management-related folders.
    # This methods initialize all [DirectoryInfo] and [System.Uri] properties
    # dealing with management folders.
    # Throws:
    #   - [UFGetManagementFolderFailureException] if a folder reference cannot
    #       be obtained.
    #   - [UFUriCreationFailureException] if a URI cannot be created.
    [void] InitManagementFolderProperties()
    {
        # Management folder
        [EventLogger]::LogVerbose("Get the management folder of the instance.")
        try
        {
            # The main management folder is always assumed to be the directory
            # of the item.
            $this.ManagementFolder = $this.File.Directory
            $this.ManagementFolderUri = (
                [System.Uri]::New($this.ManagementFolder.FullName))
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFGetManagementFolderFailureException]::New(
                $this.File, "management")
        }
        
        # Cache folder
        [EventLogger]::LogVerbose("Get the cache folder of the instance.")
        try
        {
            $this.CacheFolder = (
                [FileManager]::GetCacheFolder($this.ContentFolder))
            $this.CacheFolderUri = (
                [System.Uri]::New($this.CacheFolder.FullName))
        }
        catch [FileManagerException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFGetManagementFolderFailureException]::New(
                $this.File, "cache")
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New(
                $this.CacheFolder.FullName)
        }

        # Static folder
        [EventLogger]::LogVerbose("Get the static folder of the instance.")
        try
        {   
            $this.StaticFolder = (
                [FileManager]::GetStaticFolder($this.ContentFolder))
            $this.StaticFolderUri = (
                [System.Uri]::New($this.StaticFolder.FullName))
        }
        catch [FileManagerException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFGetManagementFolderFailureException]::New(
                $this.File, "static")
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New(
                $this.StaticFolder.FullName)
        }
    }

    # Update all properties related to the static file.
    # Throws:
    #   - [UFUriCreationFailureException] if a URI cannot be created.
    [void] UpdateStaticFileInfo()
    {
        # Build a reference to the static file.
        $this.StaticFile = [System.IO.FileInfo] (
            Join-Path `
                -Path $this.StaticFolder.FullName `
                -ChildPath $this.File.Name)

        # Create a URI to the static file
        try
        {
            $this.StaticFileUri = [System.Uri]::New($this.StaticFile.FullName)
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New($this.StaticFile)
        }

        # Update static version status
        if ($this.StaticFile.Exists)
        {
            if ($this.File.LastWriteTime -gt $this.StaticFile.LastWriteTime)
            {
                $this.StaticVersion = [FileVersionStatus]::Expired
            }
            else
            {
                $this.StaticVersion = [FileVersionStatus]::Current
            }
        }
        else
        {
            $this.StaticVersion = [FileVersionStatus]::Absent
        }
    }

    # Update all properties related to the cache file.
    # Throws:
    #   - [UFUriCreationFailureException] if a URI cannot be created.
    [void] UpdateCacheFileInfo()
    {
        # Build a reference to the cache file.
        $this.CacheFile = [System.IO.FileInfo] (
            Join-Path `
                -Path $this.CacheFolder.FullName`
                -ChildPath $this.File.Name)

        # Create a URI to the cache file
        try
        {
            $this.CacheFileUri = [System.Uri]::New($this.CacheFile.FullName)
        }
        catch [System.SystemException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFUriCreationFailureException]::New($this.CacheFile)
        }

        # Cached metadata status
        if ($this.CacheFile.Exists)
        {
            if ($this.File.LastWriteTime -gt $this.CacheFile.LastWriteTime)
            {
                $this.CachedVersion = [FileVersionStatus]::Expired
            }
            else
            {
                $this.CachedVersion = [FileVersionStatus]::Current
            }
        }
        else
        {
            $this.CachedVersion = [FileVersionStatus]::Absent
        }
    }

    ###########################################################################
    # CRUD operations
    ###########################################################################

    # Deletes the UMS file from the disk. Overrides the Delete() method from
    # the parent type to include cache and static files.
    # Throws:
    #   - [UFDeletionFailureException] on file deletion failure.
    [void] Delete()
    {
        # Delete cache file
        try
        {
            if ($this.CacheFile.Exists)
            {
                $this.CacheFile.Delete()
            }
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFDeletionFailureException]::New($this.CacheFile)
        }

        # Delete static file
        try
        {
            if ($this.StaticFile.Exists)
            {
                $this.StaticFile.Delete()
            }
        }
        catch [System.IO.IOException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFDeletionFailureException]::New($this.StaticFile)
        }

        # Delete actual UMS file (calling parent method)
        try
        {
            ([UmsFile] $this).Delete()
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }
    }

    # Deletes the UMS file and its content file from the disk. Overrides the
    # DeleteWithContentFile() from the parent type to include cache and
    # static files to the list of files to delete.
    # Throws:
    #   - [UFDeletionFailureException] on file deletion failure.
    [void] DeleteWithContentFile()
    {
        # Delete content file
        try
        {
            $this.DeleteContentFile()
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Delete UMS file (this method is already an override)
        try
        {
            $this.Delete()
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }
    }

    # Renames the UMS file, all its versions, and its content file, if any.
    # The method returns a new UmsManagedFile instance. Overrides the
    # Rename() method from the parent type to include cache and static files
    # to the rename list.
    # Throws:
    #   - [UFRenameFailureException] on rename failure.
    [UmsManagedFile] Rename([string] $NewName)
    {
        # Move cache file, if any
        if ($this.CacheFile.Exists)
        {
            # Build cache file new name
            $_cacheFileNewName = $($NewName + ([FileManager]::UmsFileExtension))
            $_cacheFileNewFullName = (
                Join-Path `
                    -Path $this.CacheFile.Directory.FullName `
                    -ChildPath $_cacheFileNewName)

            # Move cache file
            try
            {
                $this.CacheFile | Move-Item -Destination $_cacheFileNewFullName
            }
            catch [System.IO.IOException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [UFRenameFailureException]::New(
                    $this.CacheFile, $_cacheFileNewFullName)
            }
        }

        # Move static file, if any
        if ($this.StaticFile.Exists)
        {
            # Build static file new name
            $_staticFileNewName = $($NewName + ([FileManager]::UmsFileExtension))
            $_staticFileNewFullName = (
                Join-Path `
                    -Path $this.StaticFile.Directory.FullName `
                    -ChildPath $_staticFileNewName)

            # Move static file
            try
            {
                $this.StaticFile | Move-Item -Destination $_staticFileNewFullName
            }
            catch [System.IO.IOException]
            {
                [EventLogger]::LogException($_.Exception)
                throw [UFRenameFailureException]::New(
                    $this.StaticFile, $_staticFileNewFullName)
            }
        }

        # Move UMS file and content file
        # We let the parent method handle this for us
        [UmsFile] $_newUmsFileInstance = $null
        try
        {
            $_newUmsFileInstance = ([UmsFile] $this).Rename($NewName)
        }
        catch [UFDeletionFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            throw $_.Exception
        }

        # Return a new UmsManagedFile instance
        return [UmsManagedFile]::New($_newUmsFileInstance.File)
    }

    ###########################################################################
    # Static / Cached version methods
    ###########################################################################

    # Returns a deserialized entity from the cached metadata version.
    # Throws:
    #   - [UFGetCachedMetadataFailureException] when the method cannot return
    #       the cached metadata.
    [PSObject] GetCachedMetadata()
    {
        switch ($this.CachedVersion)
        {
            "Unknown"
            {
                [EventLogger]::LogError(
                    "The status of the cached version is 'Unknown'!")
                throw [UFGetCachedMetadataFailureException]::New($this.Uri)
            }
            "Absent"
            {
                [EventLogger]::LogError(
                    "The status of the cached version is 'Absent'!")
                throw [UFGetCachedMetadataFailureException]::New($this.Uri)
            }
            "Expired"
            {
                [EventLogger]::LogWarning(
                    "The status of the cached version is 'Expired'!")
            }
        }

        # Try instantiation
        [PSObject] $_metadata = $null

        try
        {
            $_metadata = Import-CliXml -Path $this.CacheFile.FullName
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFGetCachedMetadataFailureException]::New($this.Uri)
        }

        # Return deserialized metadata.
        return $_metadata
    }

    # Returns a UmsDocument instance from the static version of the file.
    # Throws:
    #   - [UFGetStaticDocumentFailureException] when the method cannot return
    #       the demanded instance.
    [UmsDocument] GetStaticDocument()
    {
        switch ($this.StaticVersion)
        {
            "Unknown"
            {
                [EventLogger]::LogError(
                    "The status of the static version is 'Unknown'!")
                throw [UFGetStaticDocumentFailureException]::New($this.Uri)
            }
            "Absent"
            {
                [EventLogger]::LogError(
                    "The status of the static version is 'Absent'!")
                throw [UFGetStaticDocumentFailureException]::New($this.Uri)
            }
            "Expired"
            {
                [EventLogger]::LogWarning(
                    "The status of the static version is 'Expired'!")
            }
        }

        # Try instantiation
        [UmsDocument] $_document = $null

        try
        {
            $_document = [DocumentFactory]::GetDocument($this.StaticFileUri)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFGetStaticDocumentFailureException]::New($this.Uri)
        }

        # Return the new instance
        return $_document
    }

    # Updates the file storing cached metadata from a supplied entity
    # instance. We cannot generate the entity from this method, as this
    # class is loaded before the [EntityFactory], and PowerShell would fail
    # to load the module to a dependency loop.
    # Tags:
    #   - DependencyLoopPrevention
    # Throws:
    #   - [UFCachedMetadataUpdateFailureException] on fatal failure.
    [void] UpdateCachedMetadata([object] $Entity)
    {
        # Get a temporary file.
        try
        {
            $_temporaryFile = New-TemporaryFile
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFCachedMetadataUpdateFailureException]::New($this.Uri)
        }

        # Get CliXml export depth
        [int] $_depth = 0
        try
        {
            $_depth = ([ConfigurationStore]::GetSystemItem(
                "ExportCliXmlDepth")).Value
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFCachedMetadataUpdateFailureException]::New($this.Uri)
        }

        # Serialize the entity
        try
        {
            $Entity | Export-CliXml `
                -Depth $_depth `
                -Path $_temporaryFile.Fullname
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            # Temporary file should be removed if caching has failed
            Remove-Item `
                -Force `
                -Path $_temporaryFile.FullName
            throw [UFCachedMetadataUpdateFailureException]::New($this.Uri)
        }

        # Promote the temporary file
        try
        {
            Copy-Item `
                -Force `
                -Path $_temporaryFile.FullName `
                -Destination $this.CacheFile.FullName `
                -ErrorAction Stop
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFCachedMetadataUpdateFailureException]::New($this.Uri)
        }
        finally
        {
            # Temporary file should be removed anyway
            Remove-Item `
            -Force `
            -Path $_temporaryFile.FullName
        }

        # Update cached version status
        $this.UpdateCacheFileInfo()
    }

    # Updates the static file linked to the managed file.
    # Throws:
    #   - [UFStaticVersionUpdateFailureException] on fatal failure.
    #   - [UFInvalidStaticVersionException] if the static version does not
    #       validate against the Relax NG schema.
    [void] UpdateStaticFile()
    {
        # Instantiate a XSLT transformer
        try
        {
            $Transformer = [XsltTransformer]::New(
                [ConfigurationStore]::GetStylesheetItem("Expander").Uri
            )
        }
        catch [ConfigurationStoreException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFStaticVersionUpdateFailureException]::New(
                $this.File)
        }
        catch [XsltTransformerException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFStaticVersionUpdateFailureException]::New(
                $this.File)
        }

        # Run the XSLT transformation
        $_arguments = @{
            "ConfigFile" = ([ConfigurationStore]::ConfigFileUri).AbsoluteUri
        }
        try
        {
            $Transformer.Transform($this.Uri, $this.StaticFile, $_arguments)
        }
        catch [XsltTransformerException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFStaticVersionUpdateFailureException]::New(
                $this.File)
        }

        # Instantiate a Relax NG validator.
        [RelaxNgValidator] $Validator = $null
        try
        {
            $Validator = [RelaxNgValidator]::New(
                $this.SchemaFileUri)
        }
        catch [RelaxNgValidatorException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [UFStaticVersionUpdateFailureException]::New(
                $this.File)
        }

        # Validate the static version
        try
        {
            $Validator.Validate($this.StaticFileUri)
        }
        catch [RNVValidationFailureException]
        {
            [EventLogger]::LogException($_.Exception)
            # Remove the invalid static file.
            $this.StaticFile | Remove-Item -Force
            throw [UFInvalidStaticVersionException]::New(
                $this.File)
        }
        finally
        {
            # Update static file info on file change
            $this.UpdateStaticFileInfo()
            # Update cardinalityInfo after static file update.
            $this.UpdateCardinalityInfo()
        }
    }
}

###############################################################################
#   Enum FileVersionStatus
#==============================================================================
#
#   Defines the status a version of a managed UMS file, such as the static file
#   version or the cached version of its metadata.
#
###############################################################################

Enum FileVersionStatus
{
    Unknown
    Absent
    Current
    Expired
}

###############################################################################
#   Enum FileCardinality
#==============================================================================
#
#   Valid cardinalities for managed UMS files.
#
###############################################################################

Enum FileCardinality
{
    Unknown
    Independent
    Sidecar
    Orphan
}