<?xml version='1.0'?>
<!--#############################################################################
 |      $Id$
 |- #############################################################################
 |      $Author$
 |
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
        exclude-result-prefixes="doc" version='1.0'>

<xsl:variable name="latex.mapping.xml" select="document('latex.mapping.xml')"/>

<xsl:template name="latex.mapping">
<xsl:param name="keyword"></xsl:param>
<xsl:param name="element.name" select="local-name(.)"/>
<xsl:variable name="latex.mapping">
	<xsl:value-of select="($latex.mapping.xml/latexmapping/mapping[@key=$keyword])[1]/@text"/>
</xsl:variable>
<xsl:if test="$latex.mapping =''">
	<xsl:message> DB2LaTeX [warning]: No mapping for <xsl:value-of select="$keyword"/></xsl:message>
</xsl:if>
<xsl:value-of select="$latex.mapping"/>
</xsl:template>
</xsl:stylesheet>

