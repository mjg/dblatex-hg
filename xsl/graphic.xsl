<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="screenshot">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="screeninfo"/>

<xsl:template match="inlinegraphic|graphic">
  <xsl:call-template name="imagedata"/>
</xsl:template>

</xsl:stylesheet>
