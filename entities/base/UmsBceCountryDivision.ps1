###############################################################################
#   Concrete entity class UmsBceCountryDivision
#==============================================================================
#
#   This class describes a country division entity, built from an XML
#    'countryDivision' element from the base namespace.
#
###############################################################################

class UmsBceCountryDivision : UmsBaeItem
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # A string inserted between each part of a multi-part place
    static [string] $PlaceListDelimiter = (
        [ConfigurationStore]::GetRenderingItem("PlaceListDelimiter").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Parent country
    [UmsBceCountry]         $Country

    # Parent countryDivision
    [UmsBceCountryDivision] $CountryDivision

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceCountryDivision(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "countryDivision")

        # Get the optional 'countryDivision' instance
        if ($XmlElement.CountryDivision)
        {
            $this.CountryDivision = [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Base,
                    "countryDivision"),
                $this.SourcePathUri,
                $this.SourceFileUri)

            # Set the country property to that of the parent countryDivision
            $this.Country = $this.CountryDivision.Country
        }

        # Else, a 'country' element is mandatory
        else
        {
            $this.Country = [EntityFactory]::GetEntity(
                $this.GetOneXmlElement(
                    $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "country"),
                $this.SourcePathUri,
                $this.SourceFileUri)
        }        
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns the string version of the place, which tries to include the
    # name of the country as a suffix.
    [string] ToString()
    {
        # Initialize empty string
        [string] $_string = ""

        # Include ToString() output for labelVariant data. This string shall be
        # void if the 'place' element has no 'labelVariants' child element.
        if (([UmsBaeItem]$this).ToString())
        {
            $_string += ([UmsBaeItem]$this).ToString()
        }

        # Add the name of the parent country or country division as a suffix
        # If a country division is set, then the parent is a country division.
        if($this.CountryDivision)
        {
            $_string += [UmsBceCountryDivision]::PlaceListDelimiter
            $_string += $this.CountryDivision.ToString()
        }
        # If no country division is set, the parent is a country
        else
        {
            $_string += [UmsBceCountryDivision]::PlaceListDelimiter
            $_string += $this.Country.ToString()
        }

        return $_string
    }
}