<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
	==============================================================================
	!
	!	Catalogs
	!
	==============================================================================
	-->
	<!-- Returns the base URI of a catalog from its namespace -->
	<xsl:template name="getCatalogUriByNamespace">
		<xsl:param name="Namespace"/>
		<xsl:value-of select="$ConfigData/catalogs/catalog[@namespace = $Namespace]/@uri"/>
	</xsl:template>
	<!-- Returns the relative URI of a catalog mapping from a catalog namespace and an element name -->
	<xsl:template name="getCatalogMappingSubpath">
		<xsl:param name="Namespace"/>
		<xsl:param name="ElementName"/>
		<xsl:value-of select="$ConfigData/catalogs/catalog[@namespace = $Namespace]/mappings/mapping[@element = $ElementName]/@subpath"/>
	</xsl:template>
	<!-- Returns the full URI of a catalog mapping hosting element with the specified name -->
	<xsl:template name="getCatalogUriForElement">
		<xsl:param name="Namespace"/>
		<xsl:param name="ElementName"/>
		<!-- Get the base URI of the catalog -->
		<xsl:variable name="_catalogUri">
			<xsl:call-template name="getCatalogUriByNamespace">
				<xsl:with-param name="Namespace" select="$Namespace"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Validate base URI -->
		<xsl:if test="normalize-space($_catalogUri) = ''">
			<xsl:message terminate="yes" select="concat('No catalog URI found for namespace ', $Namespace)"/>
		</xsl:if>
		<!-- Get the relative URI for a specific mapping -->
		<xsl:variable name="_subpath">
			<xsl:call-template name="getCatalogMappingSubpath">
				<xsl:with-param name="Namespace" select="$Namespace"/>
				<xsl:with-param name="ElementName" select="$ElementName"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Validate subpath -->
		<xsl:if test="normalize-space($_subpath) = ''">
			<xsl:message terminate="yes" select="concat('No sub-path found for element ', $ElementName)"/>
		</xsl:if>
		<!-- Final value -->
		<xsl:value-of select="$_catalogUri"/>
		<xsl:value-of select="'/'"/>
		<xsl:value-of select="$_subpath"/>
	</xsl:template>
	<!--
	==============================================================================
	!
	!	UMS options
	!
	==============================================================================
	-->
	<xsl:template name="getUmsOptionValue">
		<xsl:param name="OptionName"/>
		<xsl:param name="OptionDomain" select="'rendering'"/>
		<xsl:param name="AllowEmptyValue" select="false()"/>
		<xsl:param name="Boolean" select="false()"/>
		<!-- Get option value -->
		<xsl:variable name="_value">
			<xsl:choose>
				<xsl:when test="$OptionDomain = 'rendering'">
					<xsl:value-of select="$ConfigData/rendering/option[@id = $OptionName]"/>
				</xsl:when>
				<xsl:when test="$OptionDomain = 'system'">
					<xsl:value-of select="$ConfigData/system/option[@id = $OptionName]"/>
				</xsl:when>				
			</xsl:choose>
		</xsl:variable>
		<!-- Validate option value -->
		<xsl:if test="$AllowEmptyValue = false() and normalize-space($_value) = ''">
			<xsl:message terminate="yes" select="concat('No non-empty UMS option was found with the name ', $OptionName)"/>
		</xsl:if>
		<!-- Final value -->
		<xsl:choose>
			<xsl:when test="$Boolean = false()">
				<xsl:value-of select="$_value"/>
			</xsl:when>
			<xsl:when test="$Boolean = true()">
				<xsl:choose>
					<xsl:when test="lower-case($_value) = 'false'">
						<xsl:value-of select="false()"/>
					</xsl:when>	
					<xsl:when test="lower-case($_value) = 'true'">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes" select="concat('Invalid value for UMS option ', $OptionName, '. Expected a boolean value.')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--
	==============================================================================
	!
	!	Stylesheet options
	!
	==============================================================================
	-->
	<!-- Returns the value of a stylesheet option -->
	<xsl:template name="getStylesheetOptionValue">
		<xsl:param name="Stylesheet"/>
		<xsl:param name="OptionName"/>
		<xsl:param name="AllowEmptyValue" select="false()"/>
		<xsl:param name="Boolean" select="false()"/>
		<!-- Get option value -->
		<xsl:variable name="_value">
			<xsl:value-of select="$ConfigData/stylesheets/stylesheet[@id = $Stylesheet]/options/option[@id = $OptionName]"/>
		</xsl:variable>
		<!-- Validate option value -->
		<xsl:if test="$AllowEmptyValue = false() and normalize-space($_value) = ''">
			<xsl:message terminate="yes" select="concat('No non-empty stylesheet option was found with the name ', $OptionName)"/>
		</xsl:if>
		<!-- Final value -->
		<xsl:choose>
			<xsl:when test="$Boolean = false()">
				<xsl:value-of select="$_value"/>
			</xsl:when>
			<xsl:when test="$Boolean = true()">
				<xsl:choose>
					<xsl:when test="lower-case($_value) = 'false'">
						<xsl:value-of select="false()"/>
					</xsl:when>	
					<xsl:when test="lower-case($_value) = 'true'">
						<xsl:value-of select="true()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes" select="concat('Invalid value for stylesheet option ', $OptionName, '. Expected a boolean value.')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>