###############################################################################
#   Concrete entity class UmsBceCity
#==============================================================================
#
#   This class describes a city entity, built from an XML 'city' element from
#   the base namespace.
#
###############################################################################

class UmsBceCity : UmsBaeItem
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
    [UmsBceCountry] $Country 
    
    # Parent country division, if any
    [UmsBceCountryDivision] $CountryDivision

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBceCity([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "city")
        
        # Try to get a 'countryDivision' element
        if ($XmlElement.countryDivision)
        {
            $this.CountryDivision = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "countryDivision"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
            
            # Set the country property to that of the countryDivision
            $this.Country = $this.CountryDivision.Country
        }

        # If no 'countryDivision' element was found, a 'country' child element
        # becomes mandatory.
        else
        {
            $this.Country = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "country"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns the string version of the place, which tries to include the names
    # of the country state and of the country as suffices, if available.
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

        # If CountryDivision is set, the parent of the city is a country
        # division. We include the string representation of the country
        # division, which includes all remanining parents, as a suffix.
        if($this.CountryDivision)
        {
            $_string += [UmsBceCity]::PlaceListDelimiter
            $_string += $this.CountryDivision.ToString()
        }

        # Else, the parent is a country.
        # We Include the country string representation as a suffix.
        elseif($this.Country)
        {
            $_string += [UmsBceCity]::PlaceListDelimiter
            $_string += $this.Country.ToString()
        }

        return $_string
    }
}