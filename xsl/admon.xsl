<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX
    ############################################################################ -->

<xsl:template match="note|important|warning|caution|tip">
  <xsl:text>\begin{DBKadmonition}{</xsl:text>
  <xsl:call-template name="admon.graphic"/><xsl:text>}{</xsl:text>
  <xsl:choose> 
    <xsl:when test="title">
      <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="title"/></xsl:call-template>
    </xsl:when> 
    <xsl:otherwise>
      <xsl:call-template name="gentext.element.name"/>
    </xsl:otherwise> 
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{DBKadmonition}&#10;</xsl:text>
</xsl:template>

<xsl:template match="note/title|important/title|
                     warning/title|caution/title|tip/title"/>

<xsl:template name="admon.graphic">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="name($node)='warning'">warning</xsl:when>
    <xsl:when test="name($node)='caution'">warning</xsl:when>
    <xsl:when test="name($node)='important'">warning</xsl:when>
    <xsl:otherwise>none</xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
