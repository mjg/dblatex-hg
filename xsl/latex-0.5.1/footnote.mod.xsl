<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="footnote">
<xsl:call-template name="label.id"/>
<xsl:text> \footnote{</xsl:text><xsl:value-of select="."/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="footnoteref">
<xsl:variable name="footnote" select="id(@linkend)"/>
<xsl:value-of select="name($footnote)"/>
<xsl:text>[\ref{</xsl:text>
      <!-- xsl:apply-templates select="$footnote" mode="footnote.number"/> -->
	<xsl:value-of select="@linkend"/>
<xsl:text>}]</xsl:text>
</xsl:template>

<xsl:template match="footnote" mode="footnote.number">
  <xsl:choose>
    <xsl:when test="ancestor::table|ancestor::informaltable">
      <xsl:number level="any" from="table|informaltable" format="a"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number level="any" format="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
