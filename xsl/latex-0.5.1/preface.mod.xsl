<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="preface">
<xsl:variable name="id"><xsl:call-template name="label.id"/></xsl:variable>
<xsl:text>&#10;</xsl:text>
<xsl:text>% ------------------------------------------------------------&#10;</xsl:text>
<xsl:text>% Preface													   	&#10;</xsl:text>
<xsl:text>% ------------------------------------------------------------&#10;</xsl:text>
<xsl:text>\newpage&#10;</xsl:text>
<xsl:call-template name="preface.title"/>
<xsl:call-template name="preface.subtitle"/>
	<xsl:apply-templates/>
</xsl:template>



<xsl:template name="preface.title">
<xsl:call-template name="label.id"/>
<xsl:text>&#10;{\sc </xsl:text><xsl:apply-templates select="." mode="title.ref"/><xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template name="preface.subtitle">
<xsl:variable name="subtitle"><xsl:apply-templates select="." mode="subtitle.content"/></xsl:variable>
<xsl:if test="$subtitle != ''">
   	<xsl:text>{\sc</xsl:text><xsl:copy-of select="normalize-space($subtitle)"/><xsl:text>}</xsl:text>
</xsl:if>
</xsl:template>


<xsl:template match="preface/title"></xsl:template>
<xsl:template match="preface/titleabbrev"></xsl:template>
<xsl:template match="preface/subtitle"></xsl:template>
<xsl:template match="preface/docinfo|prefaceinfo"></xsl:template>

<xsl:template match="preface/para">
<xsl:text>&#10;\paragraph*{}&#10;</xsl:text>  <!-- This is a fixme !! -->
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="preface/sect1">
<xsl:text>&#10;\section*{</xsl:text><xsl:copy-of select="normalize-space(title)"/>}<xsl:text>&#10;</xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="preface/sect1/sect2">
<xsl:text>&#10;\subsection*{</xsl:text><xsl:copy-of select="normalize-space(title)"/>}<xsl:text>&#10;</xsl:text>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="preface/sect1/sect2/sect3">
<xsl:text>&#10;\subsubsection*{</xsl:text><xsl:copy-of select="normalize-space(title)"/>}<xsl:text>&#10;</xsl:text>
<xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>

