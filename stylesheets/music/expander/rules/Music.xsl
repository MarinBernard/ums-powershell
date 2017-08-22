<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemas.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">
	<!--
	==============================================================================
	!
	!	Transclusion rules for elements from the music namespace
	!
	==============================================================================
	-->
	<!-- Transclusion of <catalog> references -->
	<xsl:template match="umsm:catalog[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Catalogs"/>
			<xsl:with-param name="TargetElement" select="'catalog'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <composer> references -->
	<xsl:template match="umsm:composer[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Composers"/>
			<xsl:with-param name="TargetElement" select="'composer'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <conductor> references -->
	<xsl:template match="umsm:conductor[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Conductors"/>
			<xsl:with-param name="TargetElement" select="'conductor'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <ensemble> references -->
	<xsl:template match="umsm:ensemble[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Ensembles"/>
			<xsl:with-param name="TargetElement" select="'ensemble'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <form> references -->
	<xsl:template match="umsm:form[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Forms"/>
			<xsl:with-param name="TargetElement" select="'form'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <instrument> references -->
	<xsl:template match="umsm:instrument[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Instruments"/>
			<xsl:with-param name="TargetElement" select="'instrument'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <instrumentalist> references -->
	<xsl:template match="umsm:instrumentalist[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Instrumentalists"/>
			<xsl:with-param name="TargetElement" select="'instrumentalist'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <key> references -->
	<xsl:template match="umsm:key[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Keys"/>
			<xsl:with-param name="TargetElement" select="'key'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <lyricist> references -->
	<xsl:template match="umsm:lyricist[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Lyricists"/>
			<xsl:with-param name="TargetElement" select="'lyricist'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <lyrics> references -->
	<xsl:template match="umsm:lyrics[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Lyrics"/>
			<xsl:with-param name="TargetElement" select="'lyrics'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <movement> references -->
	<xsl:template match="umsm:movement[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Movements"/>
			<xsl:with-param name="TargetElement" select="'movement'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <performance> references -->
	<xsl:template match="umsm:performance[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="TargetElement" select="'performance'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <score> references -->
	<xsl:template match="umsm:score[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Scores"/>
			<xsl:with-param name="TargetElement" select="'score'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <style> references -->
	<xsl:template match="umsm:style[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Styles"/>
			<xsl:with-param name="TargetElement" select="'style'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <venue> references -->
	<xsl:template match="umsm:venue[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Venues"/>
			<xsl:with-param name="TargetElement" select="'venue'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Transclusion of <work> references -->
	<xsl:template match="umsm:work[@uid][not(*)]">
		<xsl:call-template name="Transcluder">
			<xsl:with-param name="CatalogRoot" select="$CAT_Music_Works"/>
			<xsl:with-param name="TargetElement" select="'work'"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>