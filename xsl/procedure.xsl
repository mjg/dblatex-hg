<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<xsl:template match="procedure">
  <xsl:apply-templates select="*[not(self::step)]"/>
  <xsl:text>\begin{enumerate}&#10;</xsl:text>
  <xsl:apply-templates select="step"/>
  <xsl:text>\end{enumerate}&#10;</xsl:text>
</xsl:template>

<xsl:template match="procedure/title"/>

<xsl:template match="step">
  <xsl:text>\item{</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:if test="title">
    <xsl:text>{\sc </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="substeps">
  <xsl:text>\begin{enumerate}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{enumerate}&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
