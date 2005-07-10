<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template name="index.print">
  <xsl:param name="node" select="."/>
  <!-- actual sorting entry -->
  <xsl:if test="$node/@sortas">
    <xsl:call-template name="scape.index">
      <xsl:with-param name="string" select="$node/@sortas"/>
    </xsl:call-template>
    <xsl:text>@{</xsl:text>
  </xsl:if>
  <!-- entry display -->
  <xsl:call-template name="scape.index">
    <xsl:with-param name="string" select="$node"/>
  </xsl:call-template>
  <xsl:if test="$node/@sortas">
    <xsl:text>}</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="indexterm">
  <xsl:param name="close" select="''"/>
  <xsl:text>\index{</xsl:text>
  <xsl:call-template name="index.print">
    <xsl:with-param name="node" select="./primary"/>
  </xsl:call-template>
  <xsl:if test="./secondary">
    <xsl:text>!</xsl:text>
    <xsl:call-template name="index.print">
      <xsl:with-param name="node" select="./secondary"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="./tertiary">
    <xsl:text>!</xsl:text>
    <xsl:call-template name="index.print">
      <xsl:with-param name="node" select="./tertiary"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="./see">
    <xsl:text>|see{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="./see"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>
  </xsl:if>
  <xsl:if test="./seealso">
    <xsl:text>|see{</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="./seealso"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>
  </xsl:if>
  <!-- page range opening/close -->
  <xsl:choose>
  <xsl:when test="$close!=''">
    <xsl:value-of select="$close"/>
  </xsl:when>
  <xsl:when test="@class='startofrange'">
    <!-- sanity check: only open range if related close is found -->
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
    <xsl:when test="//indexterm[@class='endofrange' and @startref=$id]">
      <xsl:text>|(</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
      <xsl:text>*** Error: cannot find indexterm[@startref='</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>'] end of range</xsl:text>
      </xsl:message>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  </xsl:choose>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- simply duplicate the referenced starting range indexterm, and close the
     range -->

<xsl:template match="indexterm[@class='endofrange']">
  <xsl:variable name="id" select="@startref"/>
  <xsl:apply-templates select="//indexterm[@class='startofrange' and @id=$id]">
    <xsl:with-param name="close" select="'|)'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="primary|secondary|tertiary|see|seealso"/>
<xsl:template match="indexentry"/>
<xsl:template match="primaryie|secondaryie|tertiaryie|seeie|seealsoie"/>

<!-- todo -->
<xsl:template match="index|setindex">
<!--
  <xsl:call-template name="label.id"/>
  <xsl:text>\printindex&#10;</xsl:text>
  -->
</xsl:template>

<xsl:template match="index/title"></xsl:template>
<xsl:template match="index/subtitle"></xsl:template>
<xsl:template match="index/titleabbrev"></xsl:template>

<xsl:template match="indexdiv">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="indexdiv/title">
  <xsl:call-template name="label.id">
    <xsl:with-param name="object" select=".."/>
  </xsl:call-template>
</xsl:template>


</xsl:stylesheet>
