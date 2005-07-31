<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template name="element.and.label">
  <xsl:call-template name="label.id">
    <xsl:with-param name="string">
      <xsl:call-template name="sec-map">
        <xsl:with-param name="keyword" select="local-name(.)"/>
      </xsl:call-template>
      <xsl:apply-templates select="title" mode="toc"/>
      <xsl:text>{</xsl:text> 
      <xsl:apply-templates select="title" mode="content"/>
      <xsl:text>}</xsl:text> 
    </xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="title" mode="foottext"/>
</xsl:template>

<xsl:template name="label.id">
  <xsl:param name="object" select="."/>
  <xsl:param name="string" select="''"/>
  <xsl:variable name="id">
    <xsl:choose>
      <xsl:when test="$object/@id">
        <xsl:value-of select="$object/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="$string"/>
  <xsl:if test="$id!=''">
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="normalize-space($id)"/>
    <xsl:text>}</xsl:text>
    <!-- beware, hyperlabel is docbook specific -->
    <xsl:text>\hyperlabel{</xsl:text>
    <xsl:value-of select="normalize-space($id)"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="title.and.label">
  <xsl:apply-templates select="title" mode="toc"/>
  <xsl:text>{</xsl:text> 
  <xsl:apply-templates select="title" mode="content"/>
  <xsl:text>}&#10;</xsl:text> 
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates select="title" mode="foottext"/>
</xsl:template>

<!-- optionally the TOC entry text can be different from the actual
     title if the title contains unsupported things -->
<xsl:template match="title" mode="toc">
  <xsl:variable name="foot" select="descendant::footnote"/>
  <xsl:if test="count($foot)&gt;0">
    <xsl:text>[</xsl:text> 
    <xsl:variable name="s">
      <xsl:apply-templates mode="footskip"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($s)"/>
    <xsl:text>]</xsl:text> 
  </xsl:if>
</xsl:template>

<xsl:template match="title" mode="content">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
