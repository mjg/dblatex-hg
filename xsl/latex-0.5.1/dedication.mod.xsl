<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->



<xsl:template match="dedication">
<xsl:call-template name="label.id"/>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:text>% Dedication	 &#10;</xsl:text>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:text>\newpage&#10;</xsl:text>
<xsl:call-template name="dedication.title"/>
<xsl:call-template name="dedication.subtitle"/>
<xsl:apply-templates/>
</xsl:template>


<xsl:template name="dedication.title">
<xsl:text>&#10;{\sc </xsl:text><xsl:apply-templates select="." mode="title.ref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template name="dedication.subtitle">
<xsl:variable name="subtitle"> <xsl:apply-templates select="." mode="subtitle.content"/> </xsl:variable>
<xsl:if test="$subtitle != ''">
	<xsl:text>{\sc </xsl:text><xsl:copy-of select="$subtitle"/><xsl:text>}</xsl:text>
</xsl:if>
</xsl:template>

<xsl:template match="dedication/title"></xsl:template>
<xsl:template match="dedication/subtitle"></xsl:template>
<xsl:template match="dedication/titleabbrev"></xsl:template>

<xsl:template match="dedication/para">
<xsl:text>&#10;\paragraph*{}&#10;</xsl:text>  <!-- This is a fixme !! -->
<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
