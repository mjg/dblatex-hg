<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- Default cover handler: put a specified image on a new physical page.
     The first <cover> is assumed to be for the front page, the second one is
     for the back page.

     The implementation tries to match the DocBook 4 method that uses
     <mediaobject>s with role='cover' to represent a cover, but it ignores those
     elements if <cover> elements are found.
-->

<xsl:template name="front.cover">
  <xsl:param name="info" select="/*/*[contains(name(.), 'info')]"/>
  <xsl:call-template name="make.cover">
    <xsl:with-param name="idx" select="1"/>
    <xsl:with-param name="info" select="$info"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="back.cover">
  <xsl:param name="info" select="/*/*[contains(name(.), 'info')]"/>
  <xsl:call-template name="make.cover">
    <xsl:with-param name="idx" select="2"/>
    <xsl:with-param name="info" select="$info"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="make.cover">
  <xsl:param name="idx" select="1"/>
  <xsl:param name="info"/>

  <xsl:variable name="covers" select="$info/cover"/>
  <xsl:variable name="medias" select="$info//mediaobject[@role='cover']"/>

  <xsl:choose>
  <xsl:when test="count($covers) &gt;= $idx">
    <xsl:apply-templates select="$covers[$idx]/mediaobject" mode="cover"/>
  </xsl:when>
  <xsl:when test="count($medias) &gt;= $idx">
    <xsl:apply-templates select="$medias[$idx]" mode="cover"/>
  </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="mediaobject" mode="cover">
  <xsl:variable name="idx">
    <xsl:call-template name="mediaobject.select.idx">
      <xsl:with-param name="role" select="'front-large'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="img" select="imageobject[position()=$idx]"/>

  <xsl:text>\putoncover{</xsl:text>
  <xsl:apply-templates select="$img/imagedata" mode="cover"/>              
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="imagedata" mode="cover">
  <xsl:call-template name="imagedata">
    <xsl:with-param name="layout.width" select="'\paperwidth'"/>
    <xsl:with-param name="layout.height" select="'\paperheight'"/>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
