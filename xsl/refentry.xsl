<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template name="subsection">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="name($node)='chapter'">sect1</xsl:when>
    <xsl:when test="name($node)='sect1'">sect2</xsl:when>
    <xsl:when test="name($node)='sect2'">sect3</xsl:when>
    <xsl:when test="name($node)='sect3'">sect4</xsl:when>
    <xsl:when test="name($node)='sect4'">sect5</xsl:when>
    <xsl:when test="name($node)='sect5'">sect6</xsl:when>
    <xsl:when test="name($node)='section'">
      <xsl:choose>
        <xsl:when test="$node/../../../../../section">sect6</xsl:when>
        <xsl:when test="$node/../../../../section">sect5</xsl:when>
        <xsl:when test="$node/../../../section">sect4</xsl:when>
        <xsl:when test="$node/../../section">sect3</xsl:when>
        <xsl:otherwise>sect2</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="name($node)='simplesect'">
      <xsl:choose>
        <xsl:when test="$node/../../sect1">sect3</xsl:when>
        <xsl:when test="$node/../../sect2">sect4</xsl:when>
        <xsl:when test="$node/../../sect3">sect5</xsl:when>
        <xsl:when test="$node/../../sect4">sect6</xsl:when>
        <xsl:when test="$node/../../sect5">sect6</xsl:when>
        <xsl:when test="$node/../../section">
          <xsl:choose>
            <xsl:when test="$node/../../../../../section">sect6</xsl:when>
            <xsl:when test="$node/../../../../section">sect5</xsl:when>
            <xsl:when test="$node/../../../section">sect4</xsl:when>
            <xsl:otherwise>sect3</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>sect2</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>sect2</xsl:otherwise>
  </xsl:choose>
</xsl:template>



<xsl:template match="refentry">
<xsl:variable name="refmeta" select=".//refmeta"/>
<xsl:variable name="refentrytitle" select="$refmeta//refentrytitle"/>
<xsl:variable name="refnamediv" select=".//refnamediv"/>
<xsl:variable name="refname" select="$refnamediv//refname"/>
<xsl:variable name="title">
	<xsl:choose>
	<xsl:when test="$refentrytitle">
		<xsl:apply-templates select="$refentrytitle[1]" mode="title"/>
	</xsl:when>
	<xsl:when test="$refname">
		<xsl:apply-templates select="$refname[1]" mode="title"/>
	</xsl:when>
	<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:text>&#10;</xsl:text>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:text>% Refentry </xsl:text><xsl:value-of select="title"/><xsl:text> &#10;</xsl:text>
<xsl:text>% -------------------------------------------------------------&#10;</xsl:text>
<xsl:variable name="sect" select="(ancestor::section
                                  |ancestor::simplesect
                                  |ancestor::chapter
                                  |ancestor::sect1
                                  |ancestor::sect2
                                  |ancestor::sect3
                                  |ancestor::sect4
                                  |ancestor::sect5)[last()]"/>

<xsl:call-template name="latex.mapping">
  <xsl:with-param name="keyword">
    <xsl:call-template name="subsection">
      <xsl:with-param name="node" select="$sect"/>
    </xsl:call-template>
  </xsl:with-param>
</xsl:call-template>
 <!--
 <xsl:value-of select="normalize-space($title)"/>
 -->
<xsl:value-of select="$title"/>
<xsl:text>}&#10;</xsl:text>
<xsl:call-template name="label.id"/>
<xsl:apply-templates/>
</xsl:template>


<!-- gentext.element.name ne marche pas. On le remplace directement par le
     libelle en francais. -->

<xsl:template match="refname[1]">
  <xsl:text>&#10;\subsection*{Nom}&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::refname">
	  <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
