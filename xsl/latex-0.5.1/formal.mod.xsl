<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template name="formal.object">
	<xsl:call-template name="formal.object.heading">
		<xsl:with-param name="title"><xsl:apply-templates select="." mode="title.ref"/></xsl:with-param>
	</xsl:call-template>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template name="formal.object.heading">
<xsl:param name="title"></xsl:param>
<xsl:variable name="id"><xsl:call-template name="label.id"/></xsl:variable>
<xsl:copy-of select="$title"/>
</xsl:template>

<xsl:template name="informal.object">
	<xsl:variable name="id"><xsl:call-template name="label.id"/></xsl:variable>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template name="semiformal.object">
	<xsl:choose>
		<xsl:when test="title">	<xsl:call-template name="formal.object"/>	</xsl:when>
		<xsl:otherwise> <xsl:call-template name="informal.object"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="equation">
<xsl:text>&#10;\begin{dbequation}&#10;</xsl:text>
<xsl:apply-templates />
<xsl:choose> 
	<xsl:when test="title">
		<xsl:text>&#10;\caption{</xsl:text>
			<xsl:call-template name="normalize-scape"> 
			 	<xsl:with-param name="string" select="title"/>
			</xsl:call-template>
		<xsl:text>}&#10;</xsl:text>
	</xsl:when> 
	<xsl:otherwise>
		<xsl:text>&#10;\caption{</xsl:text>
		<xsl:text>RCAS: Please, add a title to equations}&#10;</xsl:text>
	</xsl:otherwise> 
</xsl:choose>
<xsl:call-template name="label.id"/>
<xsl:text>&#10;\end{dbequation}&#10;</xsl:text>
</xsl:template>


<xsl:template match="informalequation">
	<xsl:call-template name="informal.object"/>
</xsl:template>

<xsl:template match="equation/title"></xsl:template>
</xsl:stylesheet>
