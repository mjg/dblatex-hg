<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<!-- it only works for bookinfo/abstract. Within chapters, etc. it puts the
     abstract in a separate page.
  -->

<xsl:template match="abstract">
  <xsl:text>&#10;</xsl:text>
  <xsl:text>% -------- &#10;</xsl:text>
  <xsl:text>% Abstract &#10;</xsl:text>
  <xsl:text>% -------- &#10;</xsl:text>
  <xsl:if test="title">
    <xsl:text>\let\savabstractname=\abstractname&#10;</xsl:text>
    <xsl:text>\def\abstractname{</xsl:text>
    <xsl:value-of select="title"/>
    <xsl:text>}</xsl:text>
  </xsl:if>
  <xsl:text>\begin{abstract}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#10;\end{abstract}&#10;</xsl:text>
  <xsl:if test="title">
    <xsl:text>\let\abstractname=\savabstractname&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="abstract/title"/>

</xsl:stylesheet>
