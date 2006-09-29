<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- These templates boost the text processing but needs some post-parsing
     to escape the TeX characters. -->

<xsl:template name="scape" >
  <xsl:param name="string"/>
  <xsl:text>&lt;t&gt;</xsl:text>
  <xsl:value-of select="$string"/>
  <xsl:text>&lt;/t&gt;</xsl:text>
</xsl:template>

<!-- tag the text for the perl script -->
<xsl:template match="text()">
  <xsl:text>&lt;t&gt;</xsl:text>
  <xsl:value-of select="."/>
  <!--
  <xsl:value-of select="normalize-space(.)"/>
  -->
  <xsl:text>&lt;/t&gt;</xsl:text>
</xsl:template>

<!-- specific behaviour for MML -->
<xsl:template match="m:*/text()">
  <xsl:call-template name="mmltext"/>
</xsl:template>

<xsl:template name="normalize-scape" >
  <xsl:param name="string"/>
  <xsl:call-template name="scape">
    <xsl:with-param name="string">
      <xsl:value-of select="normalize-space($string)"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
