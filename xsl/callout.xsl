<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="programlistingco|screenco">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="areaspec|areaset|area"/>

<xsl:template match="co">
    <xsl:apply-templates select="." mode="callout-bug"/>
</xsl:template>

<xsl:template match="co" mode="callout-bug">
  <xsl:variable name="conum">
    <xsl:number count="co" format="1"/>
  </xsl:variable>

  <xsl:text>(</xsl:text>
  <xsl:value-of select="$conum"/>
  <xsl:text>)</xsl:text>
</xsl:template>

</xsl:stylesheet>
