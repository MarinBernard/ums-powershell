<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemas.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">
	<!--
	==============================================================================
	!
	!	Transclusion rules for elements from the audio namespace
	!
	==============================================================================
	-->
	<!-- Transclusion of <album> references -->
	<xsl:template match="umsa:album[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="TargetElement" select="'album'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <label> references -->
	<xsl:template match="umsa:label[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Audio_Labels"/>
			<xsl:with-param name="TargetElement" select="'label'"/>
		</xsl:call-template>
	</xsl:template>	
</xsl:stylesheet>