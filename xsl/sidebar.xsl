<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="sidebar">
  <xsl:text>&#10;&#10;\framebox[\textwidth]{&#10;</xsl:text>
  <xsl:text>\begin{minipage}{\textwidth}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
  <xsl:text>\end{minipage}&#10;}&#10;</xsl:text>
</xsl:template>

<xsl:template match="sidebar/title">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>

