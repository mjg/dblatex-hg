<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                version="1.0">

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX
    ############################################################################ -->

<xsl:import href="latex-0.5.1/docbook.xsl"/>

<xsl:import href="common.xsl"/>
<xsl:import href="table.xsl"/>
<xsl:import href="admon.xsl"/>
<xsl:import href="revision.xsl"/>
<xsl:import href="example.xsl"/>
<xsl:import href="inlined.xsl"/>
<xsl:import href="format.xsl"/>
<xsl:import href="verbatim.xsl"/>
<xsl:import href="refentry.xsl"/>
<xsl:import href="biblio.xsl"/>
<xsl:import href="index.xsl"/>
<xsl:import href="equation.xsl"/>
<xsl:import href="footnote.xsl"/>
<xsl:import href="procedure.xsl"/>
<xsl:import href="xref.xsl"/>
<xsl:import href="misc.xsl"/>
<xsl:import href="main.xsl"/>
<xsl:import href="version.xsl"/>
<xsl:import href="param.xsl"/>
<xsl:import href="citation.xsl"/>
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
        <xsl:text>Revisionflag on unexpected element: </xsl:text>
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
