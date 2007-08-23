<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:param name="tex.math.in.alt" select="'latex'"/>

<xsl:template match="inlineequation|informalequation">
  <xsl:choose>
  <xsl:when test="alt and ($tex.math.in.alt='latex' or count(child::*)=1)">
    <xsl:apply-templates select="alt"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="*[not(self::alt)]"/>
  </xsl:otherwise>
  </xsl:choose>
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
    <!-- This is an actual LaTeX equation -->
    <xsl:text>&#10;\begin{equation}&#10;</xsl:text>
    <xsl:call-template name="label.id"/>
    <xsl:apply-templates/>
    <xsl:text>&#10;\end{equation}&#10;</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="inlineequation/graphic"/>
<xsl:template match="informalequation/graphic"/>
<xsl:template match="equation/graphic"/>
<xsl:template match="equation/title"/>
<xsl:template match="mathphrase"/>

<!-- Direct copy of the content -->

<xsl:template match="alt">
  <xsl:choose>
  <xsl:when test="ancestor::equation[not(child::title)]">
    <!-- Remove any math mode in an equation environment -->
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:variable name="len" select="string-length($text)"/>
    <xsl:choose>
    <xsl:when test="starts-with($text,'$') and substring($text,$len,$len)='$'">
      <xsl:copy-of select="substring($text, 2, $len - 2)"/>
    </xsl:when>
    <xsl:when test="(starts-with($text,'\[') and
                     substring($text,$len - 1,$len)='\]') or
                    (starts-with($text,'\(') and
                     substring($text,$len - 1,$len)='\)')">
      <xsl:copy-of select="substring($text, 3, $len - 4)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <!-- Test to be DB5 compatible, where <alt> can be in other elements -->
  <xsl:when test="ancestor::equation or
                  ancestor::informalequation or
                  ancestor::inlineequation">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
