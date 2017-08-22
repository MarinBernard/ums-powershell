<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umsb="http://schemas.olivarim.com/ums/1.0/base"
	xmlns:umsm="http://schemas.olivarim.com/ums/1.0/music">
	<!-- Returns a path from a full filename -->
	<xsl:template name="getFilePath">
		<xsl:param name="Path" />
		<xsl:choose>
			<!-- URI -->
			<xsl:when test="contains($Path,'://')">
				<xsl:value-of select="substring-before($Path,'://')" />
				<xsl:if test="contains(substring-after($Path,'://'),'/')">
					<xsl:value-of select="'://'"/>
					<xsl:call-template name="getFilePath">
						<xsl:with-param name="Path" select="substring-after($Path,'://')" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<!-- Regular path level -->
			<xsl:when test="contains($Path,'/')">
				<xsl:value-of select="substring-before($Path,'/')" />
				<xsl:if test="contains(substring-after($Path,'/'),'/')">
					<xsl:value-of select="'/'"/>
					<xsl:call-template name="getFilePath">
						<xsl:with-param name="Path" select="substring-after($Path,'/')" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	<!-- Returns a file name from a full filename -->
	<xsl:template name="getFileName">
		<xsl:param name="Path" />
		<xsl:choose>
			<!-- URI -->
			<xsl:when test="contains($Path,'://')">
				<xsl:call-template name="getFileName">
					<xsl:with-param name="Path" select="substring-after($Path,'://')" />
				</xsl:call-template>
			</xsl:when>
			<!-- Regular path level -->
			<xsl:when test="contains($Path,'/')">
				<xsl:call-template name="getFileName">
					<xsl:with-param name="Path" select="substring-after($Path,'/')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Path" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Returns a file name without the extension -->
	<xsl:template name="getFileRadical">
		<xsl:param name="Path" />
		<xsl:variable name="_fileName">
			<xsl:choose>
				<xsl:when test="contains($Path,'/')">
					<xsl:call-template name="getFileName">
						<xsl:with-param name="Path" select="$Path" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Path" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($_fileName,'.')">
				<xsl:value-of select="substring-before($_fileName,'.')" />
				<xsl:if test="contains(substring-before($_fileName,'.'),'.')">
					<xsl:value-of select="'.'"/>
					<xsl:call-template name="getFileRadical">
						<xsl:with-param name="Path" select="substring-after($_fileName,'.')" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>	
	<!-- Returns true() if a path is absolute -->
	<xsl:template name="isAbsolutePath">
		<xsl:param name="Path" />
		<xsl:choose>
			<!-- If the path is a URI, that's an absolute path -->
			<xsl:when test="contains($Path, '://')">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<!-- If the path contains a Windows path, that's an absolute path -->
			<xsl:when test="contains($Path, ':\')">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<!-- If the path begins with the root fs, that's an absolute path -->
			<xsl:when test="starts-with($Path, '/')">
				<xsl:value-of select="true()"/>
			</xsl:when>					
			<!-- Else, the path is relative -->
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>