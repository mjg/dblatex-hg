<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="para">
	<xsl:text>&#10;</xsl:text>
	<xsl:apply-templates/>
	<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="simpara">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="formalpara">
	<xsl:text>&#10;{\bf </xsl:text>
	<xsl:call-template name="normalize-scape"><xsl:with-param name="string" select="title"/></xsl:call-template>
	<xsl:text>} </xsl:text>
	<xsl:apply-templates/>
	<xsl:text>&#10;</xsl:text>
	<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="formalpara/title"></xsl:template>


<!--========================================================================== 
 |	Especial Cases Do not add Linefeed 
 +============================================================================-->

<xsl:template match="listitem/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="footnote/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="textobject/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="step/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="entry/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="question/para"> <xsl:apply-templates/> </xsl:template>
<xsl:template match="answer/para"> <xsl:apply-templates/> </xsl:template>


</xsl:stylesheet>
