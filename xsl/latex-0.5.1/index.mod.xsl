<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="index|setindex">
<xsl:call-template name="label.id"/>
<xsl:text>\printindex&#10;</xsl:text>
</xsl:template>

<xsl:template match="index/title"></xsl:template>
<xsl:template match="index/subtitle"></xsl:template>
<xsl:template match="index/titleabbrev"></xsl:template>

<xsl:template match="index/title" mode="component.title.mode">
<xsl:call-template name="label.id"> <xsl:with-param name="object" select=".."/> </xsl:call-template>
</xsl:template>

<xsl:template match="index/subtitle" mode="component.title.mode"/>




<xsl:template match="indexdiv">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="indexdiv/title">
<xsl:call-template name="label.id"> <xsl:with-param name="object" select=".."/> </xsl:call-template>
</xsl:template>


<!-- INDEX TERM CONTENT MODEL
IndexTerm ::=
(Primary,
 ((Secondary,
   ((Tertiary,
     (See|SeeAlso+)?)|
    See|SeeAlso+)?)|
  See|SeeAlso+)?)
  -->
<xsl:template match="indexterm">
<xsl:text> \index{</xsl:text>
<xsl:value-of select="normalize-space(./primary)"/>
<xsl:if test="./secondary"><xsl:text>!</xsl:text><xsl:value-of select="normalize-space(./secondary)"/></xsl:if>
<xsl:if test="./tertiary"><xsl:text>!</xsl:text><xsl:value-of select="normalize-space(./tertiary)"/></xsl:if>
<xsl:if test="./see"><xsl:text>|see{</xsl:text><xsl:value-of select="normalize-space(./see)"/>}</xsl:if>
<xsl:if test="./seealso"><xsl:text>|see{</xsl:text><xsl:value-of select="normalize-space(./seealso)"/>}</xsl:if>
<xsl:text>} </xsl:text>
</xsl:template>

<xsl:template match="primary|secondary|tertiary|see|seealso"/>
<xsl:template match="indexentry"/>
<xsl:template match="primaryie|secondaryie|tertiaryie|seeie|seealsoie"/>

</xsl:stylesheet>
