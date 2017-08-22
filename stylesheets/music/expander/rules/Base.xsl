<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemas.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">
	<!--
	==============================================================================
	!
	!	Transclusion rules for elements from the base namespace
	!
	==============================================================================
	-->
	<!-- Transclusion of references to <character> elements -->
	<xsl:template match="umsb:character[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="TargetElement" select="'character'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of references to <city> elements -->
	<xsl:template match="umsb:city[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Base_Cities"/>
			<xsl:with-param name="TargetElement" select="'city'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of references to <country> elements -->
	<xsl:template match="umsb:country[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Base_Countries"/>
			<xsl:with-param name="TargetElement" select="'country'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of references to <countryDivision> elements -->
	<xsl:template match="umsb:countryDivision[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Base_CountryDivisions"/>
			<xsl:with-param name="TargetElement" select="'countryDivision'"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>