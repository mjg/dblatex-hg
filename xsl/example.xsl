<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:param name="example.default.position">[H]</xsl:param>


<xsl:template match="example">
  <xsl:text>&#10;\begin{example}</xsl:text>
  <!-- float placement preference -->
  <xsl:choose>
    <xsl:when test="@floatstyle != ''">
      <xsl:value-of select="@floatstyle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$example.default.position"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates />
  <xsl:choose> 
    <xsl:when test="title">
      <xsl:text>&#10;\caption{</xsl:text>
        <xsl:call-template name="normalize-scape"> 
          <xsl:with-param name="string" select="title"/>
        </xsl:call-template>
      <xsl:text>}&#10;</xsl:text>
    </xsl:when> 
    <xsl:otherwise>
      <xsl:text>&#10;\caption{</xsl:text>
      <xsl:text>*** Missing title ***}&#10;</xsl:text>
    </xsl:otherwise> 
  </xsl:choose>
  <xsl:call-template name="label.id"/>
  <xsl:text>&#10;\end{example}&#10;</xsl:text>
</xsl:template>

<xsl:template match="informalexample">
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="example/title"/>

</xsl:stylesheet>
