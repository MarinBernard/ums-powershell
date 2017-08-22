###############################################################################
#   Abstract entity class UmsMaePlace
#==============================================================================
#
#   This class describes an abstract UMS entity representing a musical place.
#   It inherits the base UmsBaePlace abstract class, and adds musical venues
#   to available place types.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsMaePlace : UmsBaePlace
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

    # Musical venue, if any
    [UmsMceVenue] $Venue

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMaePlace([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsMaePlace")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Try to get an instance of a musical venue entity
        if ($XmlElement.venue)
        {
            $this.Venue = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "venue"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
            
            # Set the other properties to that of the venue
            $this.City = $this.Venue.City
            $this.CountryDivision = $this.Venue.CountryDivision
            $this.Country = $this.Venue.Country
        }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Returns the string version of the place, which tries to include the names
    # of the musical venue, city, the country state and the country if
    # available.
    [string] ToString()
    {
        # Initialize empty string
        [string] $_string = ""

        # Include ToString() output for labelVariant data. This string shall be
        # void if the 'place' element has no 'labelVariants' child element.
        $_labelToString = ([UmsBaeItem] $this).ToString()
        if ($_labelToString)
        {
            $_string += $_labelToString
        }

        # Add venue string, which includes city, countryDivision and country
        # suffices
        if($this.Venue)
        {
            if ($_labelToString)
                { $_string += [UmsBaePlace]::PlaceListDelimiter }
            $_string += $this.Venue.ToString()
        }

        # If no venue is set, we fallback to the ToString() method of the base
        # 'UmsBaePlace' type, which already knows how to deal with 'city',
        # 'countryDivision' and 'country' strings.
        else
        {
            if ($_labelToString)
                { $_string += [UmsBaePlace]::PlaceListDelimiter }
            $_string += ([UmsBaePlace] $this).ToString()
        }

        return $_string
    }
}