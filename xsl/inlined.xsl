<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:text>\textbf{</xsl:text>
  <xsl:copy-of select="$content"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:text>\emph{</xsl:text>
  <xsl:copy-of select="$content"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- Cela prend plus de temps que la version qui suit... Bizarre.
<xsl:template name="inline.monoseq">
  <xsl:text>\texttt{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:text>\texttt{\emph{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}}</xsl:text>
</xsl:template>
-->

<xsl:template name="inline.monoseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:text>\texttt{</xsl:text>
  <xsl:copy-of select="$content"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:text>\texttt{\emph{</xsl:text>
  <xsl:copy-of select="$content"/>
  <xsl:text>}}</xsl:text>
</xsl:template>

<xsl:template match="emphasis[@role='bold']">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

</xsl:stylesheet>
