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


<xsl:template match="procedure">
<xsl:if test="title"> <xsl:apply-templates select="title"/></xsl:if>
<xsl:text>\begin{enumerate}&#10;</xsl:text>
<xsl:apply-templates/>
<xsl:text>\end{enumerate}&#10;</xsl:text>
</xsl:template>

<xsl:template match="procedure/title">
<xsl:text>{\sc </xsl:text><xsl:apply-templates/><xsl:text> }&#10;</xsl:text>
</xsl:template>


<xsl:template match="step">
<xsl:choose>
	<xsl:when test="title">
		<xsl:text>\item{{\sc </xsl:text><xsl:apply-templates select="title"/><xsl:text>} &#10;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>\item{</xsl:text>
	</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates/>
<xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="procedure/title"> </xsl:template>

<xsl:template match="substeps">
<xsl:text>\begin{enumerate}&#10;</xsl:text>
<xsl:apply-templates/>
<xsl:text>\end{enumerate}&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>

