###############################################################################
#   Concrete entity class UmsMcePerformer
#==============================================================================
#
#   This class describes a music performer entity, built from a
#   'performer' XML element from the UMS music namespace.
#
###############################################################################

class UmsMcePerformer : UmsAeEntity
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # Whether the name of the played instrument should be added to the name of
    # the performer when it is rendered as a string.
    static [string] $ShowPlayedInstrument = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerPerformedInstrumentListShow").Value)

    # One or several characters which will be inserted between the names of
    # played instruments.
    static [string] $InstrumentListDelimiter = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerPerformedInstrumentListDelimiter").Value)
    
    # One or several characters which will be inserted before the name of the
    # played instrument.
    static [string] $InstrumentListPrefix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerPerformedInstrumentListPrefix").Value)

    # One or several characters which will be inserted after the name of the
    # played instrument.
    static [string] $InstrumentListSuffix = (
        [ConfigurationStore]::GetRenderingItem(
            "MusicPerformerPerformedInstrumentListSuffix").Value)

    ###########################################################################
    # Hidden properties
    ###########################################################################

    # A string suffix showing the names of played instruments.
    hidden [string] $PlayedInstrumentSuffix

    ###########################################################################
    # Visible properties
    ###########################################################################

    [UmsMceEnsemble]        $Ensemble
    [UmsMceInstrumentalist] $Instrumentalist
    [UmsMceInstrument[]]    $Instruments

    ###########################################################################
    # Constructors
    ###########################################################################

    # Standard constructor.
    UmsMcePerformer(
        [System.Xml.XmlElement] $XmlElement,
        [System.Uri] $Uri)
        : base($XmlElement, $Uri)
    {
        # Validate the XML root element
        $this.ValidateXmlElement(
            $XmlElement, [UmsAeEntity]::NamespaceUri.Music, "performer")

        # If a music ensemble is specified
        if ($XmlElement.ensemble)
        {
            # Instantiate the ensemble
            $this.Ensemble = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "ensemble"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # If the performer is not an ensemble, it has to be an instrumentalist.
        else
        {
            # Instantiate the instrumentalist
            $this.Instrumentalist = (
                [EntityFactory]::GetEntity(
                    $this.GetOneXmlElement(
                        $XmlElement,
                        [UmsAeEntity]::NamespaceUri.Music,
                        "instrumentalist"),
                    $this.SourcePathUri,
                    $this.SourceFileUri))
        }

        # Optional 'instruments' element (collection of 'instrument' elements)
        if ($XmlElement.instruments)
        {
            $this.BuildInstruments(
                $this.GetOneXmlElement(
                    $XmlElement,
                    [UmsAeEntity]::NamespaceUri.Music,
                    "instruments"))
        }

        # Build the instrument suffix
        $this.PlayedInstrumentSuffix = $this.GetPlayedInstrumentSuffix()
    }

    # Sub-constructor for the 'instruments' element
    [void] BuildInstruments([System.Xml.XmlElement] $InstrumentsElement)
    {
        $this.GetOneOrManyXmlElement(
            $InstrumentsElement,
            [UmsAeEntity]::NamespaceUri.Music,
            "instrument"
        ) | foreach {
                $this.Instruments += [EntityFactory]::GetEntity(
                    $_, $this.SourcePathUri, $this.SourceFileUri) }
    }

    ###########################################################################
    # Helpers
    ###########################################################################

    # Builds and returns the played instrument suffix.
    [string] GetPlayedInstrumentSuffix()
    {
        [string] $_suffix = ""

        # We only try to build the suffix if there is at least one instrument
        # instance.
        if ($this.Instruments.Count -gt 0)
        {
            # Gather a list of instrument names.
            [string[]] $_instruments = @()
            foreach ($_instrument in $this.Instruments)
            {
                $_instruments += $_instrument.ToString()
            }

            # Build the suffix
            $_suffix += ([UmsMcePerformer]::InstrumentListPrefix)
            $_suffix += ($_instruments -join([UmsMcePerformer]::InstrumentListDelimiter))
            $_suffix += ([UmsMcePerformer]::InstrumentListSuffix)
        }

        return $_suffix
    }

    # Renders the performer as a string, with the played instrument as an
    # optional suffix.
    [string] ToString()
    {
        $_string = ""

        if ($this.Ensemble)
        {
            # String representation of the ensemble
            $_string += $this.Ensemble.ToString()
        }
        else
        {
            # String representation of the instrumentalist
            $_string += $this.Instrumentalist.ToString()
        }

        # Show instrument suffix, if enabled.
        if (
            ([UmsMcePerformer]::ShowPlayedInstrument) -and
            ($this.PlayedInstrumentSuffix))
        {
            $_string += ([UmsAeEntity]::NonBreakingSpace)
            $_string += $this.PlayedInstrumentSuffix
        }

        return $_string
    }

}