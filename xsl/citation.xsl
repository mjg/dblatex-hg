<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX
    ############################################################################ -->

<xsl:template match="citation">
  <xsl:text>\cite{</xsl:text>
  <!-- we take the raw text: we don't want that "_" becomes "\_" -->
  <xsl:value-of select="."/>
  <xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
