###############################################################################
# Entities and classes
###############################################################################

# Event logger (Needed by all classes and helpers)
. "$PSScriptRoot\helpers\EventLogger\EventLogger.ps1"

# Base class for all exceptions (Needed by all classes and helpers)
. "$PSScriptRoot\helpers\Exceptions.ps1"

# Abstract helpers
. "$PSScriptRoot\helpers\abstract\ForeignMetadataConverter.Exceptions.ps1"
. "$PSScriptRoot\helpers\abstract\ForeignMetadataConverter.ps1"
. "$PSScriptRoot\helpers\abstract\ForeignMetadataUpdater.Exceptions.ps1"
. "$PSScriptRoot\helpers\abstract\ForeignMetadataUpdater.ps1"

# Configuration store (Needed by all classes and helpers)
. "$PSScriptRoot\helpers\ConfigurationStore\ConfigurationStore.Exceptions.ps1"
. "$PSScriptRoot\helpers\ConfigurationStore\ConfigurationStore.ps1"

# Relax NG Validator (Needed by the DocumentCache and XsltTransformer helpers)
. "$PSScriptRoot\helpers\RelaxNgValidator\RelaxNgValidator.Exceptions.ps1"
. "$PSScriptRoot\helpers\RelaxNgValidator\RelaxNgValidator.ps1"

# Document cache (Needed by the DocumentFactory helper)
. "$PSScriptRoot\helpers\DocumentCache\classes\UmsDocument.Exceptions.ps1"
. "$PSScriptRoot\helpers\DocumentCache\classes\UmsDocument.ps1"
. "$PSScriptRoot\helpers\DocumentCache\classes\CachedDocument.Exceptions.ps1"
. "$PSScriptRoot\helpers\DocumentCache\classes\CachedDocument.ps1"
. "$PSScriptRoot\helpers\DocumentCache\DocumentCache.Exceptions.ps1"
. "$PSScriptRoot\helpers\DocumentCache\DocumentCache.ps1"

# Document factory helper (Needed by the FileManager helper)
. "$PSScriptRoot\helpers\DocumentFactory\DocumentFactory.Exceptions.ps1"
. "$PSScriptRoot\helpers\DocumentFactory\DocumentFactory.ps1"

# XSLT Transformer (Needed by the UmsFile class from the FileManager helper)
. "$PSScriptRoot\helpers\XsltTransformer\XsltTransformer.Exceptions.ps1"
. "$PSScriptRoot\helpers\XsltTransformer\XsltTransformer.ps1"

# File manager helper
. "$PSScriptRoot\helpers\FileManager\FileManager.Exceptions.ps1"
. "$PSScriptRoot\helpers\FileManager\FileManager.ps1"

# Constraint validator (Needed by all stylesheets and converters)
. "$PSScriptRoot\helpers\ConstraintValidator\ConstraintValidator.Exceptions.ps1"
. "$PSScriptRoot\helpers\ConstraintValidator\ConstraintValidator.ps1"

# Abstract base entity
. "$PSScriptRoot\entities\UmsAeEntity.Exceptions.ps1"
. "$PSScriptRoot\entities\UmsAeEntity.ps1"

# EntityCache helper
. "$PSScriptRoot\helpers\EntityCache\classes\UmsCachedEntity.ps1"
. "$PSScriptRoot\helpers\EntityCache\EntityCache.Exceptions.ps1"
. "$PSScriptRoot\helpers\EntityCache\EntityCache.ps1"

# EntityFactory helper
. "$PSScriptRoot\helpers\EntityFactory\EntityFactory.Exceptions.ps1"
. "$PSScriptRoot\helpers\EntityFactory\EntityFactory.ps1"

# Vorbis Comment converter helper
. "$PSScriptRoot\helpers\VorbisCommentConverter\VorbisCommentConverter.Exceptions.ps1"
. "$PSScriptRoot\helpers\VorbisCommentConverter\VorbisCommentConverter.ps1"

# Vorbis Comment updater helper
. "$PSScriptRoot\helpers\VorbisCommentUpdater\VorbisCommentUpdater.Exceptions.ps1"
. "$PSScriptRoot\helpers\VorbisCommentUpdater\VorbisCommentUpdater.ps1"

###############################################################################
# Entities
###############################################################################

# Base namespace
. "$PSScriptRoot\entities\base\UmsBaeBinding.ps1"
. "$PSScriptRoot\entities\base\UmsBaeVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBceLabelVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBceLinkVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBceNameVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBceSymbolVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBceTitleVariant.ps1"
. "$PSScriptRoot\entities\base\UmsBaeResource.ps1"
. "$PSScriptRoot\entities\base\UmsBaeItem.ps1"
. "$PSScriptRoot\entities\base\UmsBaeStandard_Segment.ps1"
. "$PSScriptRoot\entities\base\UmsBaeStandard_IdSegment.ps1"
. "$PSScriptRoot\entities\base\UmsBaeStandard.Exceptions.ps1"
. "$PSScriptRoot\entities\base\UmsBaeStandard.ps1"
. "$PSScriptRoot\entities\base\UmsBaeStandardId.ps1"
. "$PSScriptRoot\entities\base\UmsBceStandard.ps1"
. "$PSScriptRoot\entities\base\UmsBceStandardId.ps1"
. "$PSScriptRoot\entities\base\UmsBceCountry.ps1"
. "$PSScriptRoot\entities\base\UmsBceCountryDivision.ps1"
. "$PSScriptRoot\entities\base\UmsBceCity.ps1"
. "$PSScriptRoot\entities\base\UmsBaePlace.ps1"
. "$PSScriptRoot\entities\base\UmsBcePlace.ps1"  
. "$PSScriptRoot\entities\base\UmsBaeProduct.ps1"
. "$PSScriptRoot\entities\base\UmsBaeMedium.ps1"
. "$PSScriptRoot\entities\base\UmsBaeTrack.ps1"
. "$PSScriptRoot\entities\base\UmsBaeEvent.ps1"
. "$PSScriptRoot\entities\base\UmsBceBirth.ps1"
. "$PSScriptRoot\entities\base\UmsBceCompletion.ps1"
. "$PSScriptRoot\entities\base\UmsBceDeath.ps1"
. "$PSScriptRoot\entities\base\UmsBceInception.ps1"
. "$PSScriptRoot\entities\base\UmsBceRelease.ps1"
. "$PSScriptRoot\entities\base\UmsBaePerson.ps1"
. "$PSScriptRoot\entities\base\UmsBceCharacter.ps1"
. "$PSScriptRoot\entities\base\UmsBaePublication.ps1"
# Music namespace
. "$PSScriptRoot\entities\music\MusicEntity.Exceptions.ps1"
. "$PSScriptRoot\entities\music\UmsMceVenue.ps1"
. "$PSScriptRoot\entities\music\UmsMaePlace.ps1"
. "$PSScriptRoot\entities\music\UmsMcePlace.ps1"
. "$PSScriptRoot\entities\music\UmsMaeEvent.ps1"
. "$PSScriptRoot\entities\music\UmsMcePremiere.ps1"
. "$PSScriptRoot\entities\music\UmsMceCatalog.ps1"
. "$PSScriptRoot\entities\music\UmsMceCatalogId.ps1"
. "$PSScriptRoot\entities\music\UmsMceComposer.ps1"
. "$PSScriptRoot\entities\music\UmsMceForm.ps1"
. "$PSScriptRoot\entities\music\UmsMceInstrument.ps1"
. "$PSScriptRoot\entities\music\UmsMceKey.ps1"
. "$PSScriptRoot\entities\music\UmsMceLyricist.ps1"
. "$PSScriptRoot\entities\music\UmsMceStyle.ps1"
. "$PSScriptRoot\entities\music\UmsMceMovement.ps1"
. "$PSScriptRoot\entities\music\UmsMceSection.ps1"
. "$PSScriptRoot\entities\music\UmsMceScore.ps1"
. "$PSScriptRoot\entities\music\UmsMceWork.ps1"
. "$PSScriptRoot\entities\music\UmsMceConductor.ps1"
. "$PSScriptRoot\entities\music\UmsMceEnsemble.ps1"
. "$PSScriptRoot\entities\music\UmsMceInstrumentalist.ps1"
. "$PSScriptRoot\entities\music\UmsMcePerformer.ps1"
. "$PSScriptRoot\entities\music\UmsMcePiece.ps1"
. "$PSScriptRoot\entities\music\UmsMcePerformance.ps1"
. "$PSScriptRoot\entities\music\UmsMceTrack.ps1"
#  Audio namespace
. "$PSScriptRoot\entities\audio\UmsAceLabel.ps1"
. "$PSScriptRoot\entities\audio\UmsAceMedium.ps1"
. "$PSScriptRoot\entities\audio\UmsAceAlbum.ps1"
# Bindings
. "$PSScriptRoot\entities\audio\UmsAbeAlbumTrackBinding.ps1"

###############################################################################
# Commands
###############################################################################

# Command exceptions
. "$PSScriptRoot\commands\Exceptions.ps1"

# *-ForeignMetadata
. "$PSScriptRoot\commands\ForeignMetadata\ConvertTo-ForeignMetadata.ps1"
. "$PSScriptRoot\commands\ForeignMetadata\Update-ForeignMetadata.ps1"

# *-UmsCachedDocument
. "$PSScriptRoot\commands\CachedDocument\Get-UmsCachedDocument.ps1"
. "$PSScriptRoot\commands\CachedDocument\Remove-UmsCachedDocument.ps1"

# *-UmsCachedEntity
. "$PSScriptRoot\commands\CachedEntity\Get-UmsCachedEntity.ps1"

# *-UmsDocument
. "$PSScriptRoot\commands\Document\Get-UmsDocument.ps1"

# *-UmsDocumentCache
. "$PSScriptRoot\commands\DocumentCache\Clear-UmsDocumentCache.ps1"
. "$PSScriptRoot\commands\DocumentCache\Reset-UmsDocumentCache.ps1"
. "$PSScriptRoot\commands\DocumentCache\Measure-UmsDocumentCache.ps1"

# *-UmsEntity
. "$PSScriptRoot\commands\Entity\Get-UmsEntity.ps1"

# *-UmsEntityCache
. "$PSScriptRoot\commands\EntityCache\Clear-UmsEntityCache.ps1"
. "$PSScriptRoot\commands\EntityCache\Measure-UmsEntityCache.ps1"
. "$PSScriptRoot\commands\EntityCache\Reset-UmsEntityCache.ps1"

# *-UmsFile
. "$PSScriptRoot\commands\File\Get-UmsFile.ps1"
. "$PSScriptRoot\commands\File\Rename-UmsFile.ps1"
. "$PSScriptRoot\commands\File\Remove-UmsFile.ps1"

# *-UmsFileManagement
. "$PSScriptRoot\commands\FileManagement\Enable-UmsFileManagement.ps1"
. "$PSScriptRoot\commands\FileManagement\Disable-UmsFileManagement.ps1"
. "$PSScriptRoot\commands\FileManagement\Test-UmsFileManagement.ps1"

# *-UmsManagedFile
. "$PSScriptRoot\commands\ManagedFile\Get-UmsManagedFile.ps1"
. "$PSScriptRoot\commands\ManagedFile\Remove-UmsManagedFile.ps1"
. "$PSScriptRoot\commands\ManagedFile\Rename-UmsManagedFile.ps1"
. "$PSScriptRoot\commands\ManagedFile\Update-UmsManagedFile.ps1"