<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="/">
  <xsl:message>
  <xsl:text>XSLT stylesheets DocBook -  LaTeX 2e </xsl:text>
  <xsl:text>(</xsl:text><xsl:value-of select="$version"/><xsl:text>)</xsl:text>
  </xsl:message>
  <xsl:message>===================================================</xsl:message>
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>

