###############################################################################
#   Concrete entity class UmsBceNameVariant
#==============================================================================
#
#   This class describes a name variant entity, built from an XML 'nameVariant'
#   element from the UMS base namespace.
#
###############################################################################

class UmsBceNameVariant : UmsBaeVariant
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether common names should be prefered when present
    static [bool] $PreferCommonNames = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsPreferCommonNames").Value)

    # Whether we should show pseudonyms in a person's name
    static [bool] $ShowPseudonyms = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsUsePseudonyms").Value)

    # A string which will be included as a pseudonym prefix
    static [string] $PseudonymPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsPseudonymPrefix").Value)

    # A string which will be included as a pseudonym suffix
    static [string] $PseudonymSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsPseudonymSuffix").Value)

    # A string which will split the two parts of a sort name.
    static [string] $SortNameInfix = (
        [ConfigurationStore]::GetRenderingItem(
            "VariantsSortNameInfix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # Imported raw
    hidden [string] $FirstName
    hidden [string] $SecondName
    hidden [string] $ThirdName
    hidden [string] $LastName
    hidden [string] $Particle
    hidden [string] $CommonName
    hidden [string] $Pseudonym
    hidden [string] $ShortNameRaw

    ###########################################################################
    # Visible properties
    ###########################################################################
    
    # Calculated
    [string] $FullName
    [string] $SortName
    [string] $ShortName

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceNameVariant([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "nameVariant")
        
        # Child elements
        $this.FirstName =  $this.GetOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "firstName")
        $this.SecondName = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "secondName")
        $this.ThirdName =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "thirdName")
        $this.Particle  =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "particle")
        $this.LastName  =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "lastName")
        $this.CommonName = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "commonName")
        $this.Pseudonym =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "pseudonym")
        $this.ShortNameRaw = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "shortName")

        # Buld variant flags thanks to the parent class
        $this.Flags = $this.BuildVariantFlags()

        # Calculated values are set by helpers
        $this.FullName = $this.BuildFullName()
        $this.SortName = $this.BuildSortName()
        $this.ShortName = $this.BuildShortName()
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Builds and returns the full name of a person.
    [string] BuildFullName()
    {
        # We common names are prefered and a common name is set, use it.
        if (([UmsBceNameVariant]::PreferCommonNames) -and ($this.CommonName))
        {
            return $this.CommonName
        }
        # Else, let's build a regular full name
        else
        {
            $_fullName = $this.FirstName

            if ($this.SecondName)
            {
                $_fullName += [UmsAeEntity]::NonBreakingSpace
                $_fullName += $this.SecondName
            }

            if ($this.ThirdName)
            {
                $_fullName += [UmsAeEntity]::NonBreakingSpace
                $_fullName += $this.ThirdName
            }

            if ($this.Particle)
            {
                $_fullName += [UmsAeEntity]::NonBreakingSpace
                $_fullName += $this.Particle
            }            

            if ($this.LastName)
            {
                $_fullName += [UmsAeEntity]::NonBreakingSpace
                $_fullName += $this.LastName
            }

            if (([UmsBceNameVariant]::ShowPseudonyms) -and ($this.Pseudonym))
            {
                $_fullName += [UmsAeEntity]::NonBreakingSpace
                $_fullName += [UmsBceNameVariant]::PseudonymPrefix
                $_fullName += $this.Pseudonym
                $_fullName += [UmsBceNameVariant]::PseudonymSuffix
            }

            return $_fullName
        }
    }

    # Builds and returns the sort-friendly name of a person.
    [string] BuildSortName()
    {
        # If a last name is available, we build a regular sort name.
        if ($this.LastName)
        {
            $_sortName = $this.LastName
            $_sortName += [UmsBceNameVariant]::SortNameInfix
            $_sortName += [UmsAeEntity]::NonBreakingSpace
            $_sortName += $this.FirstName

            if ($this.SecondName)
            {
                $_sortName += [UmsAeEntity]::NonBreakingSpace
                $_sortName += $this.SecondName
            }

            if ($this.ThirdName)
            {
                $_sortName += [UmsAeEntity]::NonBreakingSpace
                $_sortName += $this.ThirdName
            }

            if ($this.Particle)
            {
                $_sortName += [UmsAeEntity]::NonBreakingSpace
                $_sortName += $this.Particle
            }   

            if (([UmsBceNameVariant]::ShowPseudonyms) -and ($this.Pseudonym))
            {
                $_sortName += [UmsAeEntity]::NonBreakingSpace
                $_sortName += [UmsBceNameVariant]::PseudonymPrefix
                $_sortName += $this.Pseudonym
                $_sortName += [UmsBceNameVariant]::PseudonymSuffix
            }

            return $_sortName
        }
        # If no last name is available, there is nothing to sort
        else
            { return $this.FullName }
    }

    # Builds and returns the short name of a person
    [string] BuildShortName()
    {
        if($this.ShortNameRaw)
            { return $this.ShortNameRaw }
        else
            { return $this.LastName }
    }
    
    # String representation
    [string] ToString()
    {
        return $this.FullName
    }
}