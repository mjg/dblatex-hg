<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="videoobject">
  <xsl:apply-templates select="videodata"/>
</xsl:template>

<xsl:template match="audioobject">
  <xsl:apply-templates select="audiodata"/>
</xsl:template>

<xsl:template match="textobject">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mediaobject|inlinemediaobject">
  <xsl:choose>
    <xsl:when test="imageobject">
      <xsl:apply-templates select="imageobject[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="textobject[1]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="imageobject">
  <xsl:apply-templates select="imagedata"/>
</xsl:template>

<xsl:template match="imagedata" name="imagedata">
  <xsl:variable name="filename">
    <xsl:choose>
    <xsl:when test="@fileref">
      <xsl:value-of select="@fileref"/>
    </xsl:when>
    <xsl:when test="@entityref">
      <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
    </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="width">
    <xsl:choose>
    <xsl:when test="contains(@width, '%') and substring-after(@width, '%')=''">
      <xsl:value-of select="number(substring-before(@width, '%')) div 100"/>
      <xsl:text>\linewidth</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@width"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="count(../../../mediaobject[imageobject]) &gt; 1">
    <xsl:text>\subfigure[</xsl:text>
    <xsl:value-of select="../../caption"/>
    <xsl:text>]</xsl:text>
  </xsl:if>
  <xsl:text>{\includegraphics[</xsl:text>
  <xsl:choose>
    <xsl:when test="@scale"> 
      <xsl:text>scale=</xsl:text>
      <xsl:value-of select="number(@scale) div 100"/>
    </xsl:when>
    <xsl:when test="@width and (not(@scalefit) or @scalefit='1')">
      <xsl:text>width=</xsl:text>
      <xsl:value-of select="normalize-space($width)"/>
    </xsl:when>
    <xsl:when test="@depth and (not(@scalefit) or @scalefit='1')">
      <xsl:text>height=</xsl:text>
      <xsl:value-of select="normalize-space(@depth)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>width=\linewidth</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@format = 'PRN'">
    <xsl:text>,angle=270</xsl:text>
  </xsl:if>
  <xsl:text>]{</xsl:text>
  <xsl:value-of select="$filename"/>
  <xsl:text>}}\quad&#10;</xsl:text>
</xsl:template>


</xsl:stylesheet>

