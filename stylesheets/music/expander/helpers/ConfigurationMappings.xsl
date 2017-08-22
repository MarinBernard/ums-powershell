<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemass.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemass.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemass.olivarim.com/ums/1.0/music">
	<!--
	==============================================================================
	!
	!	Load configuration
	!
	==============================================================================
	-->
	<!-- Load configuration -->
	<xsl:variable name="ConfigData">
		<xsl:if test="not(document($ConfigFile))">
			<xsl:message terminate="yes" select="concat('Failed to load config file: ', $ConfigFile)"/>
		</xsl:if>
		<xsl:copy-of select="document($ConfigFile)/configuration/*"/>
	</xsl:variable>
	<!--
	==============================================================================
	!
	!	UMS options
	!
	==============================================================================
	-->
	<!-- Extension of UMS files -->
	<xsl:variable name="CFG_UMSFileExtension">
		<xsl:call-template name="getUmsOptionValue">
			<xsl:with-param name="OptionDomain" select="'system'"/>
			<xsl:with-param name="OptionName" select="'ums-file-extension'"/>
		</xsl:call-template>
	</xsl:variable>
	<!--
	==============================================================================
	!
	!	Base catalog URIs
	!
	==============================================================================
	-->
	<!-- URI to the catalog of base city elements -->
	<xsl:variable name="CAT_Base_Cities">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/base'"/>
			<xsl:with-param name="ElementName" select="'city'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of base country elements -->
	<xsl:variable name="CAT_Base_Countries">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/base'"/>
			<xsl:with-param name="ElementName" select="'country'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of base countryDivision elements -->
	<xsl:variable name="CAT_Base_CountryDivisions">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/base'"/>
			<xsl:with-param name="ElementName" select="'countryDivision'"/>
		</xsl:call-template>
	</xsl:variable>
	<!--
	==============================================================================
	!
	!	Audio catalog URIs
	!
	==============================================================================
	-->
	<!-- URI to the catalog of audio label elements -->
	<xsl:variable name="CAT_Audio_Labels">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/audio'"/>
			<xsl:with-param name="ElementName" select="'label'"/>
		</xsl:call-template>
	</xsl:variable>
	<!--
	==============================================================================
	!
	!	Music catalog URIs
	!
	==============================================================================
	-->
	<!-- URI to the catalog of catalog music elements -->
	<xsl:variable name="CAT_Music_Catalogs">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'catalog'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of composer music elements -->
	<xsl:variable name="CAT_Music_Composers">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'composer'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of conductor music elements -->
	<xsl:variable name="CAT_Music_Conductors">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'conductor'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of ensemble music elements -->
	<xsl:variable name="CAT_Music_Ensembles">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'ensemble'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of form music elements -->
	<xsl:variable name="CAT_Music_Forms">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'form'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of instrumentalist music elements -->
	<xsl:variable name="CAT_Music_Instrumentalists">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'instrumentalist'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of instrument music elements -->
	<xsl:variable name="CAT_Music_Instruments">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'instrument'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of key music elements -->
	<xsl:variable name="CAT_Music_Keys">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'key'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of lyricist music elements -->
	<xsl:variable name="CAT_Music_Lyricists">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'lyricist'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of lyrics music elements -->
	<xsl:variable name="CAT_Music_Lyrics">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'lyrics'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of movement music elements -->
	<xsl:variable name="CAT_Music_Movements">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'movement'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of score music elements -->
	<xsl:variable name="CAT_Music_Scores">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'score'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of style music elements -->
	<xsl:variable name="CAT_Music_Styles">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'style'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of venue music elements -->
	<xsl:variable name="CAT_Music_Venues">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'venue'"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- URI to the catalog of work music elements -->
	<xsl:variable name="CAT_Music_Works">
		<xsl:call-template name="getCatalogUriForElement">
			<xsl:with-param name="Namespace" select="'http://schemas.olivarim.com/ums/1.0/music'"/>
			<xsl:with-param name="ElementName" select="'work'"/>
		</xsl:call-template>
	</xsl:variable>
</xsl:stylesheet>