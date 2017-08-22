###############################################################################
#   Exception class UEMandatoryStandardIdSegmentNotFoundException
#==============================================================================
#
#   Thrown when a mandatory segment is missing for a StandardId segment
#   collection.
#
###############################################################################

# Thrown when an UMS item update failed.
class UEMandatoryStandardIdSegmentNotFoundException : UmsEntityException
{
    UEMandatoryStandardIdSegmentNotFoundException(
        [object] $Segment
    ) : base()
    {
        $this.MainMessage = ($(
            "A mandatory ID segment was not found in the segment " + `
            "collection: missing level {0} segment.") -f $Segment.Order)
    }
}