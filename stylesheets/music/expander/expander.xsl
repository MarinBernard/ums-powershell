<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemas.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">
	<!--
	==============================================================================
	!
	!	Parameters
	!
	==============================================================================
	-->
	<xsl:param name="ConfigFile" select="'file:///configuration.xml'"/>
	<!--
	==============================================================================
	!
	!	Inclusions
	!
	==============================================================================
	-->
	<xsl:include href="../common/helpers/Configuration.xsl"/>
	<xsl:include href="../common/helpers/Paths.xsl"/>
	<xsl:include href="helpers/ConfigurationMappings.xsl"/>
	<xsl:include href="helpers/Transcluder.xsl"/>
	<xsl:include href="rules/Audio.xsl"/>
	<xsl:include href="rules/Base.xsl"/>
	<xsl:include href="rules/Music.xsl"/>
	<!--
	==============================================================================
	!
	!	Base templates
	!
	==============================================================================
	-->
	<xsl:output method="xml" indent="yes"/>
	<!-- This base template duplicates source XML by default -->
	<xsl:template match="text()|*|@*">
		<xsl:copy>
			<xsl:apply-templates select="text()|*|@*"/>
		</xsl:copy>
	</xsl:template>
	<!-- We copy the xml-model processing instruction -->
	<xsl:template match="processing-instruction('xml-model')">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>