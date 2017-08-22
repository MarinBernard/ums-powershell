###############################################################################
#   Concrete entity class UmsBaeMedium
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic medium.
#   It deals with properties defined in the 'Medium' abstract type from the XML
#   schema.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeMedium : UmsBaeProduct
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # The format of medium numbers in string representations.
    static [string] $MediumNumberFormat = (
        [ConfigurationStore]::GetRenderingItem("MediumNumberFormat").Value)

    # One or several characters which will be inserted before the side of the
    # medium when it is rendered as a string.
    static [string] $MediumSidePrefix = (
        [ConfigurationStore]::GetRenderingItem("MediumSidePrefix").Value)

    # One or several characters which will be inserted after the side of the
    # medium when it is rendered as a string.
    static [string] $MediumSideSuffix = (
        [ConfigurationStore]::GetRenderingItem("MediumSideSuffix").Value)

    # Whether the title of the medium will be shown when rendered as a string.
    static [bool] $ShowMediumTitle = (
        [ConfigurationStore]::GetRenderingItem("MediumTitleShow").Value)

    # One or several characters which will be inserted before the title of the
    # medium when it is rendered as a string.
    static [string] $MediumTitlePrefix = (
        [ConfigurationStore]::GetRenderingItem("MediumTitlePrefix").Value)

    # One or several characters which will be inserted after the title of the
    # medium when it is rendered as a string.
    static [string] $MediumTitleSuffix = (
        [ConfigurationStore]::GetRenderingItem("MediumTitleSuffix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    [int]               $Number
    [int]               $Side
    [UmsBaeMediumType]  $Type

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBaeMedium([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Verbose prefix
        $_verbosePrefix = "[UmsBaeMedium]::UmsBaeMedium(): "

        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeMedium")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Attributes
        $this.Number = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "number")
        $this.Side = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "side")
        $this.Type = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "type")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns the string representation of the medium.
    [string] ToString()
    {
        $_string = ""

        # Include medium type and number
        $_string += $this.Type
        $_string += ([UmsAeEntity]::NonBreakingSpace)
        $_string += ([UmsBaeMedium]::MediumNumberFormat -f $this.Number)

        # Include medium side, if defined
        if ($this.Side -gt 0)
        {
            $_string += ([UmsAeEntity]::NonBreakingSpace)
            $_string += ([UmsBaeMedium]::MediumSidePrefix)
            $_string += $this.Side
            $_string += ([UmsBaeMedium]::MediumSideSuffix)
        }

        # Include medium title, if defined. We use the ToString() method
        # from the UmsBaeProduct base type to get the string.
        $_fullTitle = ([UmsBaeProduct] $this).ToString()
        if (([UmsBaeMedium]::ShowMediumTitle) -and ($_fullTitle))
        {
            $_string += ([UmsAeEntity]::NonBreakingSpace)
            $_string += ([UmsBaeMedium]::MediumTitlePrefix)
            $_string += $_fullTitle
            $_string += ([UmsBaeMedium]::MediumTitleSuffix)
        }

        return $_string
    }
}

# Supported base medium types
Enum UmsBaeMediumType
{
    CDDA
}