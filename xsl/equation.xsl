<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="inlineequation|informalequation">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="equation">
  <xsl:choose>
  <xsl:when test="title">
    <xsl:text>&#10;\begin{dbequation}[H]&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;\caption{</xsl:text>
    <xsl:call-template name="normalize-scape">
       <xsl:with-param name="string" select="title"/>
    </xsl:call-template>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
    <xsl:text>&#10;\end{dbequation}&#10;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="inlineequation/graphic"/>
<xsl:template match="informalequation/graphic"/>
<xsl:template match="equation/graphic"/>
<xsl:template match="equation/title"/>

<!-- Direct copy of the content -->

<xsl:template match="alt">
  <xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>
