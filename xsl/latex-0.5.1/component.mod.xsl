<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template name="component.title">
<xsl:variable name="id">
	<xsl:call-template name="label.id"><xsl:with-param name="object" select="."/></xsl:call-template>
</xsl:variable>
<xsl:text>&#10;{\sc </xsl:text><xsl:apply-templates select="." mode="title.ref"/><xsl:text>}</xsl:text>
</xsl:template>



<xsl:template name="component.subtitle">
<xsl:variable name="subtitle"><xsl:apply-templates select="." mode="subtitle.content"/></xsl:variable>
<xsl:if test="$subtitle != ''">
	<xsl:text>&#10;{\sc </xsl:text><xsl:copy-of select="$subtitle"/><xsl:text>}</xsl:text>
</xsl:if>
</xsl:template>

<xsl:template name="component.separator">
</xsl:template>


<xsl:template match="colophon">
	<xsl:variable name="id"><xsl:call-template name="label.id"/></xsl:variable>
		<xsl:call-template name="component.separator"/>
		<xsl:call-template name="component.title"/>
		<xsl:call-template name="component.subtitle"/>
	<xsl:apply-templates/>
</xsl:template>
<xsl:template match="colophon/title"></xsl:template>



<xsl:template match="bibliography" mode="component.number">
	<xsl:param name="add.space" select="false()"/>
</xsl:template>

<xsl:template match="glossary" mode="component.number">
	<xsl:param name="add.space" select="false()"/>
</xsl:template>

<xsl:template match="index" mode="component.number">
	<xsl:param name="add.space" select="false()"/>
</xsl:template>

</xsl:stylesheet>

