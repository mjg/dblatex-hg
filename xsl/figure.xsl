<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="figure|informalfigure">
  <xsl:variable name="title">
    <xsl:choose>
    <xsl:when test="title">
      <xsl:value-of select="title"/>
    </xsl:when>
    <xsl:when test="count(mediaobject)=1 and mediaobject/caption">
      <xsl:value-of select="mediaobject/caption"/>
    </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:text>\begin{figure}</xsl:text>
  <xsl:value-of select="$latex.figure.position"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>\begin{center}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#10;\end{center}&#10;</xsl:text>
  <xsl:text>\caption{</xsl:text>
  <xsl:if test="$title">
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="$title"/>
    </xsl:call-template>
  </xsl:if> 
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:text>\end{figure}&#10;</xsl:text>
</xsl:template>

<xsl:template match="figure/title"> </xsl:template>
<xsl:template match="informalfigure/title"> </xsl:template>

</xsl:stylesheet>

