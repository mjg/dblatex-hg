<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="processing-instruction()"/>

<!-- raw latex text, e.g "<?latex \sloppy ?>" -->

<xsl:template match="processing-instruction('latex')">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="processing-instruction('db2latex')">
  <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
