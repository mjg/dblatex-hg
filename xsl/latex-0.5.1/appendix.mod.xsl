<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>
 
<xsl:template match="appendix[1]">
<xsl:text>% ------------------------------------------------------------- &#10;</xsl:text>
<xsl:text>% Appendixes start here&#10;</xsl:text>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:text>\appendix&#10;</xsl:text>
<xsl:call-template name="appendix.template" />
</xsl:template>

<xsl:template match="appendix">
<xsl:call-template name="appendix.template" />
</xsl:template>


<xsl:template name="appendix.template">
<xsl:variable name="normalized.title">
	<xsl:call-template name="normalize-scape">
	<xsl:with-param name="string" select="title"/>
	</xsl:call-template>
</xsl:variable>
<xsl:text>% ------------------------------------------------------------- &#10;</xsl:text>
<xsl:text>% Appendix </xsl:text> <xsl:value-of select="$normalized.title"/> <xsl:text>&#10;</xsl:text>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:choose>
	<xsl:when test="local-name(..)='book' or local-name(..)='part'">
	<xsl:text>\chapter{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	<xsl:text>\section{</xsl:text><xsl:copy-of select="$normalized.title"/><xsl:text>}&#10;</xsl:text>
	</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="label.id"/>
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="appendix/title"></xsl:template>
<xsl:template match="appendix/titleabbrev"></xsl:template>
<xsl:template match="appendix/subtitle"></xsl:template>
<xsl:template match="appendix/docinfo|appendixinfo"></xsl:template>
</xsl:stylesheet>

