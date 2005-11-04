<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="sect1|sect2|sect3|sect4|sect5">
  <xsl:call-template name="element.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="sect1/title"/>
<xsl:template match="sect2/title"/>
<xsl:template match="sect3/title"/>
<xsl:template match="sect4/title"/>
<xsl:template match="sect5/title"/>

<xsl:template name="map.sect.level">
  <xsl:param name="level" select="''"/>
  <xsl:param name="name" select="''"/>
  <xsl:param name="num" select="'1'"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:choose>
  <xsl:when test="$level &lt; 6">
    <xsl:choose>
      <xsl:when test='$level=1'>\section</xsl:when>
      <xsl:when test='$level=2'>\subsection</xsl:when>
      <xsl:when test='$level=3'>\subsubsection</xsl:when>
      <xsl:when test='$level=4'>\paragraph</xsl:when>
      <xsl:when test='$level=5'>\subparagraph</xsl:when>
      <!-- rare case -->
      <xsl:when test='$level=0'>\chapter</xsl:when>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="$name!=''">
    <xsl:choose>
      <xsl:when test="$name='sect1'">\section</xsl:when>
      <xsl:when test="$name='sect2'">\subsection</xsl:when>
      <xsl:when test="$name='sect3'">\subsubsection</xsl:when>
      <xsl:when test="$name='sect4'">\paragraph</xsl:when>
      <xsl:when test="$name='sect5'">\subparagraph</xsl:when>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:message>*** section level &gt; 6 not well supported</xsl:message> 
    <xsl:text>\subparagraph</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
  <xsl:when test="$num = '0'">
    <xsl:text>*</xsl:text>
  </xsl:when>
  <xsl:when test="ancestor::preface|ancestor::colophon|
                  ancestor::dedication|ancestor::partintro|
                  ancestor::glossary|ancestor::qandaset">
    <xsl:text>*</xsl:text>
  </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="section">
  <xsl:variable name="min">
    <xsl:choose>
    <xsl:when test="ancestor::appendix and ancestor::article">
      <xsl:value-of select="'2'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'1'"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level" select="count(ancestor::section)+$min"/>
  </xsl:call-template>
  <xsl:call-template name="title.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="get.sect.level">
  <xsl:param name="n" select="."/>
  <xsl:choose>
  <xsl:when test="$n/parent::section">
    <xsl:value-of select="count($n/ancestor::section)+1"/>
  </xsl:when>
  <xsl:when test="$n/parent::chapter">1</xsl:when>
  <xsl:when test="$n/parent::article">1</xsl:when>
  <xsl:when test="$n/parent::sect1">2</xsl:when>
  <xsl:when test="$n/parent::sect2">3</xsl:when>
  <xsl:when test="$n/parent::sect3">4</xsl:when>
  <xsl:when test="$n/parent::sect4">5</xsl:when>
  <xsl:when test="$n/parent::sect5">6</xsl:when>
  <xsl:when test="$n/parent::reference">1</xsl:when>
  <xsl:when test="$n/parent::preface">1</xsl:when>
  <xsl:when test="$n/parent::simplesect">
    <xsl:variable name="l">
      <xsl:call-template name="get.sect.level">
        <xsl:with-param name="n" select="$n/parent::simplesect"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$l+1"/>
  </xsl:when>
  <xsl:when test="$n/parent::book">0</xsl:when>
  <xsl:when test="$n/parent::part">0</xsl:when>
  <xsl:otherwise>7</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="simplesect">
  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level">
      <xsl:call-template name="get.sect.level"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="title.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="section/title"/>
<xsl:template match="simplesect/title"/>

<xsl:template match="sectioninfo"/>
<xsl:template match="sect1info"/>
<xsl:template match="sect2info"/>
<xsl:template match="sect3info"/>
<xsl:template match="sect4info"/>
<xsl:template match="sect5info"/>

<xsl:template match="titleabbrev"/>

</xsl:stylesheet>
