<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsa="http://schemas.olivarim.com/ums/1.0/audio"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">

	<!-- Transclusion of references to composers -->
	<xsl:template name="Transcluder">
		<!--======================================================================
		 !	Template parameters
		 =========================================================================-->
		<!-- Path to a catalog root, if such catalog exists -->
		<xsl:param name="CatalogRoot"/>
		<!-- Name of the target element to include -->
		<xsl:param name="TargetElement"/>
		<!--======================================================================
		 !	Processing
		 =========================================================================-->
		<!-- Storing the target UID -->
		<xsl:variable name="_targetUid" select="@uid"/>
		
		<!-- Retrieving the path of the current, calling document -->
		<xsl:variable name="_currentDocumentPath">
			<xsl:call-template name="getFilePath">
				<xsl:with-param name="Path" select="base-uri(.)"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- Building the file name of the target document -->
		<xsl:variable name="_targetDocumentName" select="concat(@uid, $CFG_UMSFileExtension)"/>
		
		<!-- Trying to acquire the document in a remote catalog -->
		<xsl:variable name="_documentFullPathToCatalogItem">
			<xsl:choose>
				<!-- Searching in the specified catalog -->
				<xsl:when test="document(concat($CatalogRoot, '/', $_targetDocumentName))">
					<xsl:value-of select="concat($CatalogRoot, '/', $_targetDocumentName)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Trying to acquire the document using a relative path -->
		<xsl:variable name="_documentFullPathToIndependentItem">
			<xsl:choose>					
				<!-- Using a relative path -->					
				<xsl:when test="document(concat($_currentDocumentPath, '/', $_targetDocumentName))">
					<xsl:value-of select="concat($_currentDocumentPath, '/', $_targetDocumentName)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>		
		
		<!-- Trying to acquire the full path of the target document -->
		<xsl:variable name="_documentFullPath">
			<xsl:choose>
				<!-- Searching in the specified catalog -->
				<xsl:when test="$_documentFullPathToCatalogItem != ''">
					<xsl:value-of select="$_documentFullPathToCatalogItem"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>					
						<!-- Searching in relative path -->					
						<xsl:when test="$_documentFullPathToIndependentItem != ''">
							<xsl:value-of select="$_documentFullPathToIndependentItem"/>
						</xsl:when>
						<!-- We halt here if no file was found -->
						<xsl:otherwise>
							<xsl:message terminate="yes" select="concat('ERROR: A reference to a *', $TargetElement, '* element was unresolved: ', $_targetDocumentName)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Whether the path to the target document is relative -->
		<xsl:variable name="_documentPathIsRelative">
			<xsl:choose>
				<xsl:when test="$_documentFullPathToCatalogItem != ''">
					<xsl:value-of select="false()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="true()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Checking whether target element is valid -->
		<xsl:if test="not(document($_documentFullPath)/*[local-name()=$TargetElement])">
			<xsl:message terminate="yes" select="concat('ERROR: Transclusion failure: root element of file ',
			$_documentFullPath, ' did not match our expectations. Expected element: ', $TargetElement)"/>
		</xsl:if>
		
		<!-- Performing transclusion -->
		<xsl:copy select="document($_documentFullPath)/*[local-name()=$TargetElement]">
			<xsl:attribute name="uid" select="$_targetUid"/>
			<xsl:attribute name="src" select="$_documentFullPath"/>
			<xsl:apply-templates select="*"/>
		</xsl:copy>

	</xsl:template>
</xsl:stylesheet>