###############################################################################
#   Exception class ForeignMetadataUpdaterException
#==============================================================================
#
#   Parent type for all exceptions thrown by foreign metadata updaters.
#
###############################################################################

class ForeignMetadataUpdaterException : UmsException
{
    ForeignMetadataUpdaterException() : base()
    {
        $this.MainMessage = "Foreign metadata update has failed."
    }
}

###############################################################################
#   Exception class FMUConstructionFailureException
#==============================================================================
#
#   Thrown by the constructor of a foreign metadata updater on construction
#   failure.
#
###############################################################################

class FMUConstructionFailureException : ForeignMetadataUpdaterException
{
    FMUConstructionFailureException() : base()
    {
        $this.MainMessage = (
            "The constructor encountered a fatal failure.")
    }
}

###############################################################################
#   Exception class FMUEmbeddedVersionUpdateException
#==============================================================================
#
#   Thrown on embedded version update failure.
#
###############################################################################

class FMUEmbeddedVersionUpdateException : ForeignMetadataUpdaterException
{
    FMUEmbeddedVersionUpdateException([System.IO.FileInfo] $File) : base()
    {
        $this.MainMessage = ($(
            "Unable to update the embedded version of foreign metadata " + `
            "within the following content file: {0}") `
            -f $File.FullName)
    }
}

###############################################################################
#   Exception class FMUGetExternalVersionFileException
#==============================================================================
#
#   Thrown on embedded version update failure.
#
###############################################################################

class FMUGetExternalVersionFileException : ForeignMetadataUpdaterException
{
    FMUGetExternalVersionFileException([System.IO.FileInfo] $File) : base()
    {
        $this.MainMessage = (
            "Unable to build the name of the external version file " + `
            "for the following UMS file: {0}" `
            -f $File.FullName)
    }
}

###############################################################################
#   Exception class FMUExternalVersionUpdateException
#==============================================================================
#
#   Thrown on external version update failure.
#
###############################################################################

class FMUExternalVersionUpdateException : ForeignMetadataUpdaterException
{
    FMUExternalVersionUpdateException([System.IO.FileInfo] $File) : base()
    {
        $this.MainMessage = ($(
            "Unable to update the external version of foreign metadata " + `
            "for the following UMS file: {0}") `
            -f $File.FullName)
    }
}