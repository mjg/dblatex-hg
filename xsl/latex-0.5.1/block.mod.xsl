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

<xsl:template name="block.object">
<xsl:call-template name="label.id"/> 
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="blockquote">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="epigraph">
<xsl:apply-templates select="para"/>
</xsl:template>

<xsl:template match="attribution">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="sidebar">
<xsl:call-template name="label.id"/>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="sidebar/title">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="ackno">
<xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>
