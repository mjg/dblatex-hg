<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                version="1.0">

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX
    ############################################################################ -->

<xsl:import href="docbook.xsl"/>
<xsl:import href="mathml2/mathml.xsl"/>


<xsl:template match="*[@revisionflag]">
  <xsl:choose>
    <xsl:when test="local-name(.) = 'para'
                    or local-name(.) = 'section'
                    or local-name(.) = 'appendix'">
      <xsl:text>\cbstart{}</xsl:text>
      <xsl:apply-imports/>
      <xsl:text>\cbend{}&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="local-name(.) = 'phrase'
                    or local-name(.) = 'ulink'
                    or local-name(.) = 'xref'">
      <xsl:text>\cbstart{}</xsl:text>
      <xsl:apply-imports/>
      <xsl:text>\cbend{}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>*** Revisionflag on unexpected element: </xsl:text>
        <xsl:value-of select="local-name(.)"/>
        <xsl:text>(Assuming block)</xsl:text>
      </xsl:message>
      <xsl:text>\cbstart{}</xsl:text>
      <xsl:apply-imports/>
      <xsl:text>\cbend{}&#10;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
