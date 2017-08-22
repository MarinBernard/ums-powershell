###############################################################################
#   Abstract entity class UmsBaeVariant
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic language
#   variant. It does not have an equivalent abstract element in the XML schema.
#   This class includes routines common to all concrete *variant classes, such
#   as UmsBceNameVariant, UmsBceLabelVariant, UmsBceTitleVariant, etc.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeVariant : UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Variant flags
    hidden [UmsVariantFlag[]] $Flags    

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Common to all types of language variants
    [string] $Language
    [bool]   $IsDefault
    [bool]   $IsOriginal

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeVariant")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Attributes
        $this.Language = $this.GetMandatoryXmlAttributeValue(
            $XmlElement, "lang")
        $this.IsDefault = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "default")
        $this.IsOriginal = $this.GetOptionalXmlAttributeValue(
            $XmlElement, "original")
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Build and returns the variant's flags
    [UmsVariantFlag[]] BuildVariantFlags()
    {
        [UmsVariantFlag[]] $_flags = @()

        if ($this.Language -eq [UmsAeEntity]::PreferredLanguage)
            { $_flags += [UmsVariantFlag]::Preferred }

        if (([UmsAeEntity]::UseDefaultVariants) -and ($this.IsDefault))
            { $_flags += [UmsVariantFlag]::Default }

        if ($this.Language -eq [UmsAeEntity]::FallbackLanguage)
            { $_flags += [UmsVariantFlag]::Fallback }

        if (([UmsAeEntity]::UseOriginalVariants) -and ($this.IsOriginal))
            { $_flags += [UmsVariantFlag]::Original }

        return $_flags
    }

    ###########################################################################
    # Static helpers
    ###########################################################################

    # Elects and returns the best variant from a collection of variants.
    static [UmsBaeVariant] GetBestVariant([UmsBaeVariant[]] $Variants)
    {
        # Variant in the preferred language
        $_variant = $Variants |
            Where-Object { $_.Flags -contains [UmsVariantFlag]::Preferred }
        if ($_variant) { return $_variant | Select-Object -First 1 }

        # Variant in the default language
        $_variant = $Variants |
            Where-Object { $_.Flags -contains [UmsVariantFlag]::Default }
        if ($_variant) { return $_variant | Select-Object -First 1 }

        # Variant in the fallback language
        $_variant = $Variants |
            Where-Object { $_.Flags -contains [UmsVariantFlag]::Fallback }
        if ($_variant) { return $_variant | Select-Object -First 1 }

        # Variant in the original language
        $_variant = $Variants |
            Where-Object { $_.Flags -contains [UmsVariantFlag]::Original }
        if ($_variant) { return $_variant | Select-Object -First 1 }

        # Else, return a random name variant
        return $Variants | Select-Object -First 1
    }
}

###############################################################################
#
#   Enum types used by UmsBaeVariant and its children
#
###############################################################################

Enum UmsVariantFlag
{
    Preferred
    Fallback
    Default
    Original
}