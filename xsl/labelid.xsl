<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Title parameters -->
<xsl:param name="titleabbrev.in.toc">1</xsl:param>


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
  <xsl:param name="inline" select="0"/>
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
    <xsl:text>}</xsl:text>
    <xsl:if test="$inline=0">
      <xsl:text>%&#10;</xsl:text>
    </xsl:if>
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
     title if the title contains unsupported things like hot links
     or graphics, or if some titleabbrev is provided and should be used
     for the TOC.
 -->
<xsl:template match="title" mode="toc">
  <!-- Use the titleabbrev for the TOC (if possible) -->
  <xsl:variable name="abbrev">
    <xsl:if test="$titleabbrev.in.toc='1'">
      <xsl:apply-templates
        mode="toc.skip"
        select="(../titleabbrev
                |../sect1info/titleabbrev
                |../sect2info/titleabbrev
                |../sect3info/titleabbrev
                |../sect4info/titleabbrev
                |../sect5info/titleabbrev
                |../sectioninfo/titleabbrev
                |../chapterinfo/titleabbrev
                |../partinfo/titleabbrev
                |../refsect1info/titleabbrev
                |../refsect2info/titleabbrev
                |../refsect3info/titleabbrev
                |../refsectioninfo/titleabbrev
                |../referenceinfo/titleabbrev
                )[1]"/>
    </xsl:if>
  </xsl:variable>

  <!-- Nothing in the TOC for unnumbered sections -->
  <xsl:variable name="unnumbered"
                select="parent::refsect1
                       |parent::refsect2
                       |parent::refsect3
                       |parent::refsection
                       |parent::preface
                       |parent::colophon
                       |parent::dedication"/>

  <xsl:if test="not($unnumbered) and
                ($abbrev!='' or
                (descendant::footnote|
                 descendant::xref|
                 descendant::link|
                 descendant::ulink|
                 descendant::anchor|
                 descendant::inlinegraphic|
                 descendant::inlinemediaobject))">
    <xsl:text>[{</xsl:text> 
    <xsl:choose>
    <xsl:when test="$abbrev!=''">
      <!-- The TOC contains the titleabbrev content -->
      <xsl:value-of select="normalize-space($abbrev)"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- The TOC contains the toc-safe title -->
      <xsl:variable name="s">
        <xsl:apply-templates mode="toc.skip"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($s)"/>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}]</xsl:text> 
  </xsl:if>
</xsl:template>

<xsl:template match="title" mode="content">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
