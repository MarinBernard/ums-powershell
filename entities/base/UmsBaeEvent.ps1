###############################################################################
#   Abstract entity class UmsBaeEvent
#==============================================================================
#
#   This class describes an abstract UMS entity representing a generic event.
#   It deals with properties defined in the 'Event' abstract type from the XML
#   schema, and mostly includes date and time information.
#
#   This class must *NOT* be instantiated, but rather be inherited by concrete 
#   entity classes.
#
###############################################################################

class UmsBaeEvent : UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # The format of full date strings when rendered as text
    static [string] $FullDateFormat = (
        [ConfigurationStore]::GetRenderingItem("DateFormatFull").Value)

    # The format of partial (month and year) date strings when rendered as text
    static [string] $YearMonthDateFormat = (
        [ConfigurationStore]::GetRenderingItem("DateFormatYearMonth").Value)
    
    # The format of partial (year) date strings when rendered as text
    static [string] $YearDateFormat = (
        [ConfigurationStore]::GetRenderingItem("DateFormatYear").Value)

    # A string inserted between the date and the place of an event when it is
    # rendered as text.
    static [string] $EventDatePlaceDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "EventDatePlaceDelimiter").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    hidden [string] $DateRaw
    hidden [string] $Year
    hidden [string] $Month

    ###########################################################################
    # Visible properties
    ###########################################################################

    # Date of the event
    [System.DateTime] $Date
    
    # Place of the event
    [UmsBcePlace] $Place

    ###########################################################################
    # Constructors
    ###########################################################################

    # Abstract constructor, to be called by child constructors.
    UmsBaeEvent([System.Xml.XmlElement] $XmlElement, [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Instantiation of an abstract class is forbidden
        if ($this.getType().Name -eq "UmsBaeEvent")
        {
            throw [UEAbstractEntityInstantiationException]::New(
                $this.getType().Name)
        }

        # Child elements (date)
        $this.DateRaw =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "date")
        $this.Year = $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "year")
        $this.Month =  $this.GetZeroOrOneXmlElementValue(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Base, "month")

        # DateTime object is built by a helper method
        $this.BuildDate()

        # Instantiate the optional place child element
        # We have to validate the namespace of the place element as the
        # UmsMcePlace child class expects the same element name from its own
        # namespace.
        if ($XmlElement.place)
        {
            if ($XmlElement.place.NamespaceUri -eq 
                [UmsAeEntity]::NamespaceUri.Base)
            {
                $this.Place = (
                    [EntityFactory]::GetEntity(
                        $this.GetOneXmlElement(
                            $XmlElement,
                            [UmsAeEntity]::NamespaceUri.Base,
                            "place"),
                        $this.SourcePathUri,
                        $this.SourceFileUri))
            }
        }

    }

    # Subconstructor for the Date DateTime object
    [void] BuildDate(){
        # If a full date is available, let's use it
        if ($this.DateRaw)
            { $this.Date = Get-Date -Date $this.DateRaw }

        # Else, we build a partial date
        elseif ($this.Year)
        {
            if ($this.Month)
            {
                $this.Date = (Get-Date -Year $this.Year -Month $this.Month `
                    -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0)
            }
            else
            {
                $this.Date = (Get-Date -Year $this.Year -Month 1 -Day 1 `
                    -Hour 0 -Minute 0 -Second 0 -Millisecond 0)
            }
        }
    }   

    ###########################################################################
    # Helpers
    ########################################################################### 

    # Returns the string representation of the event, which includes the event
    # date, followed by its place information.
    [string] ToString()
    {
        $_string = ""

        # Add date info
        if ($this.Date)
        {
            # If a 'date' element was specified, a full date is available
            if ($this.DateRaw)
            {
                $_string += (Get-Date `
                    -Format ([UmsBaeEvent]::FullDateFormat) `
                    -Date $this.Date)
            }
            
            # Else, we have to deal with a partial date.
            elseif ($this.Month)
            {
                $_string += (Get-Date `
                    -Format ([UmsBaeEvent]::YearMonthDateFormat) `
                    -Date $this.Date)
            }

            # Else, we have to deal with a partial date
            elseif ($this.Year)
            {
                $_string += (Get-Date `
                    -Format ([UmsBaeEvent]::YearDateFormat) `
                    -Date $this.Date)
            }
        }

        # Add place info
        if ($this.Place)
        {
            if ($this.Date)
                { $_string += [UmsBaeEvent]::EventDatePlaceDelimiter }
            $_string += ($this.Place.ToString())
        }

        return $_string
    }

}