<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="legalnotice">
  <xsl:text>\def\DBKlegaltitle{</xsl:text>
  <xsl:apply-templates select="title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>\begin{DBKlegalnotice}&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
  <xsl:text>\end{DBKlegalnotice}&#10;</xsl:text>
</xsl:template>

<xsl:template match="legalnotice/title">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="print.legalnotice">
  <xsl:param name="nodes" select="."/>
  <xsl:if test="$nodes">
    <xsl:text>
%% ------------
%% Legalnotices
%% ------------
\renewcommand{\DBKlegalblock}{
</xsl:text>
    <xsl:apply-templates select="$nodes"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
