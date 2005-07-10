<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- #############
     # reference #
     ############# -->

<xsl:template match="reference">
  <xsl:text>&#10;</xsl:text>
  <xsl:text>% Reference &#10;</xsl:text>
  <xsl:text>% ---------&#10;</xsl:text>
  <xsl:call-template name="element.and.label"/>
  <xsl:apply-templates select="partintro"/>
  <xsl:apply-templates select="*[local-name(.) != 'partintro']"/>
</xsl:template>

<xsl:template match="reference/docinfo"/>
<xsl:template match="reference/title"/>  
<xsl:template match="reference/subtitle"/>
<xsl:template match="refentryinfo|refentryinfo/*"/>

<!-- ############
     # refentry #
     ############ -->

<xsl:template match="refentry">
  <xsl:variable name="refmeta" select=".//refmeta"/>
  <xsl:variable name="refentrytitle" select="$refmeta//refentrytitle"/>
  <xsl:variable name="refnamediv" select=".//refnamediv"/>
  <xsl:variable name="refname" select="$refnamediv//refname"/>
  <xsl:variable name="title">
    <xsl:choose>
    <xsl:when test="$refentrytitle">
      <xsl:apply-templates select="$refentrytitle[1]"/>
    </xsl:when>
    <xsl:when test="$refname">
      <xsl:apply-templates select="$refname[1]"/>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
  </xsl:variable>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>% Refentry &#10;</xsl:text>
  <xsl:text>% ---------&#10;</xsl:text>

  <xsl:call-template name="map.sect.level">
    <xsl:with-param name="level">
      <xsl:call-template name="get.sect.level"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="$title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refmeta"/>

<xsl:template match="refentrytitle">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="manvolnum">
  <xsl:if test="$refentry.xref.manvolnum != 0">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<!-- ###############
     # refsynopsis #
     ############### -->

<xsl:template match="refsynopsisdiv">
  <xsl:text>&#10;\subsection*{</xsl:text>
  <xsl:choose>
  <xsl:when test="title">
    <xsl:value-of select="title"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$refsynopsis.title"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refsynopsisdivinfo"/>
<xsl:template match="refsynopsisdiv/title"/>

<!-- ##############
     # refnamediv #
     ############## -->

<xsl:template match="refnamediv">
  <xsl:text>&#10;\subsection*{</xsl:text>
  <xsl:choose>
  <xsl:when test="$refnamediv.title=''">
    <xsl:call-template name="gentext.element.name">
      <xsl:with-param name="element.name" select="'refname'"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select= "$refnamediv.title"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>}</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:text>&#10;</xsl:text>
  <!-- refdescriptor is used only if no refname -->
  <xsl:choose>
  <xsl:when test="refname">
    <xsl:apply-templates select="refname"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="refdescriptor"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates select="*[local-name(.)!='refname' and
                                 local-name(.)!='refdescriptor']"/>
</xsl:template>

<xsl:template match="refname">
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::refname">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="refpurpose">
  <xsl:text> -- </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refdescriptor">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refclass">
  <xsl:if test="@role">
    <xsl:value-of select="@role"/>
    <xsl:text>: </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<!-- ############
     # refsectx #
     ############ -->

<xsl:template match="refsect1|refsect2|refsect3">
  <xsl:call-template name="element.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="refsect1/title"/>
<xsl:template match="refsect2/title"/>
<xsl:template match="refsect3/title"/>
<xsl:template match="refsection/title"/>
<xsl:template match="refsect1info"/>
<xsl:template match="refsect2info"/>
<xsl:template match="refsect3info"/>

<xsl:template match="refsection">
  <xsl:call-template name="map.sect.level">
    <!-- its starts from subsection, so level+1 -->
    <xsl:with-param name="level" select="count(ancestor::refsection)+2"/>
    <xsl:with-param name="num" select="0"/>
  </xsl:call-template>
  <xsl:call-template name="title.and.label"/>
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
