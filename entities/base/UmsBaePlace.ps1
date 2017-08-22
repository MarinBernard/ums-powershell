###############################################################################
#   Abstract entity class UmsBaePlace
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic place.
#   It deals with properties defined in the 'Place' abstract type from the XML
#   schema, and includes various standard place information.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaePlace : UmsBaeItem
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

    # Parent country state, if any
    [UmsBceCountryDivision] $CountryDivision

    # Parent city
    [UmsBceCity] $City

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsBaePlace([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaePlace")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Try to get an instance of a city entity
        if ($XmlElement.city)
        {
            $this.City = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "city"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
            
            # Set the other properties to that of the City
            $this.CountryDivision = $this.City.CountryDivision
            $this.Country = $this.City.Country
        }
        
        # Try to get an instance of a countryDivision entity
        elseif ($XmlElement.countryDivision)
        {
            $this.CountryDivision = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Base,
                        "countryDivision"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
            
            # Set the country property to that of the CountryDivision
            $this.Country = $this.CountryDivision.Country
        }

        # Try to get an instance of a country entity
        elseif ($XmlElement.country)
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
    # of the city, the country state and the country as suffices, if available.
    [string] ToString()
    {
        # Initialize empty string
        [string] $_string = ""
        $_addDelimiter = $false

        # Include ToString() output for labelVariant data. This string shall be
        # void if the 'place' element has no 'labelVariants' child element.
        $_labelToString = ([UmsBaeItem] $this).ToString()
        if ($_labelToString)
        {
            $_string += $_labelToString
            $_addDelimiter = $true
        }

        # If City is set, the parent of the venue is a city. We include the
        # string representation of the city, which includes all remanining
        # parents, as a suffix.
        if($this.City)
        {
            if ($_addDelimiter -eq $true)
                { $_string += [UmsBaePlace]::PlaceListDelimiter }
            $_string += $this.City.ToString()
            $_addDelimiter = $true
        }

        # If CountryDivision is set, the parent of the venue is a country
        # division. We include the string representation of the country
        # division, which includes all remanining parents, as a suffix.
        elseif($this.CountryDivision)
        {
            if ($_addDelimiter -eq $true)
                { $_string += [UmsBaePlace]::PlaceListDelimiter }
            $_string += $this.CountryDivision.ToString()
            $_addDelimiter = $true
        }

        # Else, the parent of the venue must be a country, and we include its
        # string representation as a suffix.
        elseif($this.Country)
        {
            if ($_addDelimiter -eq $true)
                { $_string += [UmsBaePlace]::PlaceListDelimiter }
            $_string += $this.Country.ToString()
            $_addDelimiter = $true
        }

        return $_string
    }
}