###############################################################################
#   Class UmsDocumentCache
#==============================================================================
#
#   This class implements a caching mechanism for UMS documents.
#
###############################################################################

class ConfigurationStore
{
    ###########################################################################
    # Static properties
    ###########################################################################

    # A reference to the in-memory XML representation of the configuration
    static [System.Xml.XmlDocument] $ConfigurationDocument

    # A reference to the source configuration file.
    static [System.IO.FileInfo] $ConfigFile
    # URI to the source configuration file.
    static [System.Uri] $ConfigFileUri

    # Internal representation of the 'configuration/catalogs' section
    static [PSCustomObject[]] $Catalogs
    # Internal representation of the 'configuration/helpers' section
    static [PSCustomObject[]] $Helpers
    # Internal representation of the 'configuration/rendering' section
    static [PSCustomObject[]] $RenderingOptions
    # Internal representation of the 'configuration/schemas' section
    static [PSCustomObject[]] $Schemas
    # Internal representation of the 'configuration/system' section
    static [PSCustomObject[]] $SystemOptions
    # Internal representation of the 'configuration/stylesheets' section
    static [PSCustomObject[]] $Stylesheets
    # Internal representation of the 'configuration/tools' section
    static [PSCustomObject[]] $Tools

    ###########################################################################
    # Configuration loader
    ###########################################################################

    # Loads and reads a configuration file, then call the ParseConfiguration()
    # method, which parses the XML document update configuration properties.
    # Returns CSLoadConfigurationException if an unrecoverable error is met.
    static LoadConfiguration([System.IO.FileInfo] $ConfigFile)
    {
        try
        {
            # Store a reference to the source configuration file.
            [ConfigurationStore]::ConfigFile = $ConfigFile
            # Store a URI to the source configuration file.
            [ConfigurationStore]::ConfigFileUri = [System.Uri]::New(
                $ConfigFile.FullName)
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [CSLoadConfigurationException]::New($ConfigFile)
        }

        # Try to load config file content
        try
        {
            $_configContent = Get-Content `
                -Encoding UTF8 `
                -Path $ConfigFile `
                -ErrorAction Stop
        }
        catch
        {
            [EventLogger]::LogException($_.Exception)
            throw [CSLoadConfigurationException]::New($ConfigFile)
        }

        # Try to parse the config file to XML
        $_configDocument = [System.Xml.XmlDocument]::New()
        try
        {
            $_configDocument.LoadXml($_configContent)
        }
        catch [System.Xml.XmlException]
        {
            [EventLogger]::LogException($_.Exception)
            throw [CSLoadConfigurationException]::New($ConfigFile)
        }

        # Store the configuration document
        [ConfigurationStore]::ConfigurationDocument = $_configDocument

        # Parse config file
        [ConfigurationStore]::ParseConfiguration()
    }

    ###########################################################################
    # Parsers
    ###########################################################################

    # Parses the configuration document loaded into ::ConfigurationDocument.
    # Updates configuration properties to settings taken from this document.
    # Returns CSParseConfigurationException if an unrecoverable error is met.
    static ParseConfiguration()
    {
        # Throw an exception if the configuration store is not initialized.
        if ([ConfigurationStore]::ConfigurationDocument -eq $null)
        {
            throw [CSUninitializedStoreException]::New()
        }
        
        # Parse the '/configuration/catalogs' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/catalogs").Node
        [ConfigurationStore]::Catalogs = (
            [ConfigurationStore]::ParseCatalogs($_section))

        # Parse the '/configuration/helpers' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/helpers").Node
        [ConfigurationStore]::Helpers = (
            [ConfigurationStore]::ParseHelpers($_section))

        # Parse the '/configuration/schemas' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/schemas").Node
        [ConfigurationStore]::Schemas = (
            [ConfigurationStore]::ParseSchemas($_section))

        # Parse the '/configuration/rendering' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/rendering").Node
        [ConfigurationStore]::RenderingOptions = (
            [ConfigurationStore]::ParseGenericOptions(
                $_section, "RenderingOption"))

        # Parse the '/configuration/stylesheets' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/stylesheets").Node
        [ConfigurationStore]::Stylesheets = (
            [ConfigurationStore]::ParseStylesheets($_section))

        # Parse the '/configuration/system' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/system").Node
        [ConfigurationStore]::SystemOptions = (
            [ConfigurationStore]::ParseGenericOptions(
                $_section, "SystemOption"))

        # Parse the '/configuration/tools' section
        $_section = ([ConfigurationStore]::ConfigurationDocument |
            Select-Xml -XPath "/configuration/tools").Node
        [ConfigurationStore]::Tools = (
            [ConfigurationStore]::ParseTools($_section))
    }

    # Parses the "catalogs" section of the configuration document.
    # Cannot meet any unrecoverable error.
    static [PSCustomObject[]] ParseCatalogs([System.Xml.XmlElement] $Catalogs)
    {
        [PSCustomObject[]] $_catalogs = @()

        foreach ($_catalog in ($Catalogs | Select-Xml -XPath "catalog"))
        {
            # Building catalog mappings
            $_section = ($_catalog.Node | 
                Select-Xml -XPath "mappings").Node
            [PSCustomObject[]] $_mappings = (
                [ConfigurationStore]::ParseCatalogMappings(
                    $_section))

            # Create a catalog object
            $_catalogs += New-Object -Type PSCustomObject -Property (
                [ordered] @{
                    Type = "Catalog";
                    Id = $_catalog.Node.id;
                    ShortName = $_catalog.Node.id.Replace("-", "");
                    XmlNamespace = $_catalog.Node.namespace;
                    Uri = $($_catalog.Node.uri + "/");
                    Mappings = $_mappings; })
        }

        return $_catalogs
    }

    # Parses the 'catalog/mappings' section of the configuration document.
    # Cannot encounter any unrecoverable error.
    static [PSCustomObject[]] ParseCatalogMappings(
        [System.Xml.XmlElement] $Mappings)
    {
        [PSCustomObject[]] $_mappings = @()

        foreach ($_mapping in ($Mappings | Select-Xml -XPath "mapping"))
        {
            $_mappings += New-Object -Type PSCustomObject -Property(
                [ordered] @{
                    Element = $_mapping.Node.GetAttribute("element");
                    SubPath = $_mapping.Node.GetAttribute("subpath");
            })
        }

        return $_mappings
    }

    # Parses a generic 'constraints' section in the configuration document.
    # Cannot encounter any unrecoverable error.
    static [PSCustomObject[]] ParseGenericConstraints(
        [System.Xml.XmlElement] $Constraints,
        [string] $TypeName)
    {
        [PSCustomObject[]] $_constraints = @()

        foreach (
            $_constraint in ($Constraints | Select-Xml -XPath "constraint"))
        {
            $_constraints += New-Object -Type PSCustomObject -Property(
                [ordered] @{
                    Type = $TypeName;
                    Id = $_constraint.Node.id;
                    ShortName = $_constraint.Node.id.Replace("-", "");
                    Value = $_constraint.Node.'#Text';
            })
        }

        return $_constraints
    }

    # Parses a generic 'options' section in the configuration document.
    # Cannot encounter any unrecoverable error.
    static [PSCustomObject[]] ParseGenericOptions(
        [System.Xml.XmlElement] $Options,
        [string] $TypeName)
    {
        [PSCustomObject[]] $_options = @()

        foreach ($_option in ($Options | Select-Xml -XPath "option"))
        {
            # Try to cast the value to boolean, if supported
            [bool] $_out = $null
            $_res = [System.Boolean]::TryParse($_option.Node.'#text', [ref] $_out)
            if ($_res)
                { $_value = $_out }
            else
                { $_value = $_option.Node.'#text' }
            
            $_options += New-Object -Type PSCustomObject -Property (
                [ordered] @{
                    Type = $TypeName;
                    Id = $_option.Node.id;
                    ShortName = $_option.Node.id.Replace("-", "");
                    Value = $_value;
            })
        }

        return $_options
    }

    # Parses the "helpers" section of the configuration document.
    # Cannot meet any unrecoverable error.
    static [PSCustomObject[]] ParseHelpers(
        [System.Xml.XmlElement] $Helpers)
    {
        [PSCustomObject[]] $_helpers = @()

        foreach ($_helper in ($Helpers | Select-Xml -XPath "helper"))
        {
            # Building converter constraints
            $_section = ($_helper.Node | 
                Select-Xml -XPath "constraints").Node
            [PSCustomObject[]] $_constraints = (
                [ConfigurationStore]::ParseGenericConstraints(
                    $_section, "HelperConstraint"))

            # Building converter options
            $_section = ($_helper.Node | 
                Select-Xml -XPath "options").Node
            [PSCustomObject[]] $_options = (
                [ConfigurationStore]::ParseGenericOptions(
                    $_section, "HelperOption"))                    

            # Building helper object
            $_helpers += New-Object -Type PSCustomObject -Property (
                [ordered] @{
                    Type = "Helper";
                    Id = $_helper.Node.id;
                    ShortName = $_helper.Node.id.Replace("-", "");
                    Constraints = $_constraints;
                    Options = $_options;
            })
        }

        return $_helpers
    }

    # Parses the "schemas" section of the configuration document.
    # Cannot meet any unrecoverable error.
    static [PSCustomObject[]] ParseSchemas(
        [System.Xml.XmlElement] $Schemas)
    {
        [PSCustomObject[]] $_schemas = @()

        foreach ($_schema in ($Schemas | Select-Xml -XPath "schema"))
        {              
            # Building converter object
            $_schemas += New-Object -Type PSCustomObject -Property @{
                Type = "Schema";
                Id = $_schema.Node.GetAttribute("id");
                ShortName = $_schema.Node.GetAttribute("id").Replace("-", "");
                Namespace = $_schema.Node.GetAttribute("namespace");
                Uri = $_schema.Node.GetAttribute("uri");
            }  
        }

        return $_schemas
    }

    # Parses the "stylesheets" section of the configuration document.
    # Cannot meet any unrecoverable error.
    static [PSCustomObject[]] ParseStylesheets(
        [System.Xml.XmlElement] $Stylesheets)
    {
        [PSCustomObject[]] $_stylesheets = @()

        foreach (
            $_stylesheet in ($Stylesheets | Select-Xml -XPath "stylesheet"))
        {
            # Building stylesheet constraints
            $_section = ($_stylesheet.Node | 
                Select-Xml -XPath "constraints").Node
            [PSCustomObject[]] $_constraints = (
                [ConfigurationStore]::ParseGenericConstraints(
                    $_section, "StylesheetConstraint"))

            # Building stylesheet options
            $_section = ($_stylesheet.Node | 
                Select-Xml -XPath "options").Node
            [PSCustomObject[]] $_options = (
                [ConfigurationStore]::ParseGenericOptions(
                    $_section, "StylesheetOption"))                    

            # Create absolute path and URI
            $_relativePath = $_stylesheet.Node.GetAttribute("relpath")
            $_fullPath = Join-Path `
                -Path $global:ModuleRoot `
                -ChildPath $_relativePath
            $_uri = [System.Uri]::New($_fullPath)

            # Building stylesheet object
            $_stylesheets += New-Object -Type PSCustomObject -Property (
                [ordered] @{
                    Type = "Stylesheet";
                    Id = $_stylesheet.Node.GetAttribute("id");
                    FullPath = $_fullPath;
                    RelativePath = $_relativePath;
                    Uri = $_uri;
                    ShortName = (
                        $_stylesheet.Node.GetAttribute("id").Replace("-", ""));
                    Constraints = $_constraints;
                    Options = $_options;
            })
        }

        return $_stylesheets
    }

    # Parses the "tools" section of the configuration document.
    # Cannot meet any unrecoverable error.
    static [PSCustomObject[]] ParseTools([System.Xml.XmlElement] $Tools)
    {
        [PSCustomObject[]] $_tools = @()

        foreach ($_tool in ($Tools | Select-Xml -XPath "tool"))
        {              
            # Building converter object
            $_tools += New-Object -Type PSCustomObject -Property @{
                Type = "Tool";
                Id = $_tool.Node.id;
                ShortName = $_tool.Node.id.Replace("-", "");
                Path = $_tool.Node.path;
            }  
        }

        return $_tools
    }

    ###########################################################################
    # Getters
    ###########################################################################

    # Main getter function. Returns any configuration item of any type and with
    # any short name.
    # Throws CSGetConfigurationItemException if an unknown type or name is met.
    static [PSCustomObject[]] GetConfigurationItem(
        [string] $Type,
        [string] $ShortName)
    {
        # Throw an exception if the configuration store is not initialized.
        if ([ConfigurationStore]::ConfigurationDocument -eq $null)
        {
            throw [CSUninitializedStoreException]::New()
        }

        [PSCustomObject[]] $_collection = @()

        switch ($Type)
        {
            "catalog"
            {
                $_collection = [ConfigurationStore]::Catalogs
            }

            "helper"
            {
                $_collection = [ConfigurationStore]::Helpers
            }

            "rendering"
            {
                $_collection = [ConfigurationStore]::RenderingOptions
            }

            "schema"
            {
                $_collection = [ConfigurationStore]::Schemas
            }

            "system"
            {
                $_collection = [ConfigurationStore]::SystemOptions
            }
            
            "stylesheet"
            {
                $_collection = [ConfigurationStore]::Stylesheets
            } 

            "tool"
            {
                $_collection = [ConfigurationStore]::Tools
            } 
            
            # Throw an exception if the type of the configuration item is
            # unknown.
            default
            {
                throw [CSGetConfigurationItemException]::New($Type, $ShortName)
            }
        }

        # Filter the collection by short name, if one is specified.
        if ($ShortName.Length -gt 0)
        {
            $_collection = $_collection | 
                Where-Object { $_.ShortName -eq $ShortName }
            
            # Throw an exception if no configuration item was found with the
            # specified short name, or if more than one was found.
            if ($_collection.Count -ne 1)
            {
                throw [CSGetConfigurationItemException]::New($Type, $ShortName)
            }
        }
        
        return $_collection
    }

    # Same as the main ::GetConfigurationItem() method, with no specified short
    # name. Returns all items from the specified type.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetConfigurationItem([string] $Type)
    {
        return [ConfigurationStore]::GetConfigurationItem($Type, "")
    }

    # Proxy getter for catalog configuration items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetCatalogItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "catalog", $ShortName)
    }

    # Proxy getter for helper items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetHelperItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "helper", $ShortName)
    }

    # Proxy getter for configuration items dealing with rendering.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetRenderingItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "rendering", $ShortName)
    }

    # Proxy getter for schema configuration items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetSchemaItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "schema", $ShortName)
    }

    # Proxy getter for stylesheet items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetStylesheetItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "stylesheet", $ShortName)
    }

    # Proxy getter for system configuration items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetSystemItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "system", $ShortName)
    }

    # Proxy getter for tool configuration items.
    # Propagates exceptions thrown by the main ::GetConfigurationItem() method.
    static [PSCustomObject[]] GetToolItem([string] $ShortName)
    {
        return [ConfigurationStore]::GetConfigurationItem(
            "tool", $ShortName)
    }
}