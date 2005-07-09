<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="appendix">
  <xsl:variable name="normalized.title">
    <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="title"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="not (preceding-sibling::appendix)">
    <xsl:text>% ---------------------&#10;</xsl:text>
    <xsl:text>% Appendixes start here&#10;</xsl:text>
    <xsl:text>% ---------------------&#10;</xsl:text>
    <xsl:text>\appendix&#10;</xsl:text>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="local-name(..)='book' or local-name(..)='part'">
      <xsl:text>\chapter{</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>\section{</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:copy-of select="$normalized.title"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="appendix/title"></xsl:template>
<xsl:template match="appendix/titleabbrev"></xsl:template>
<xsl:template match="appendix/subtitle"></xsl:template>
<xsl:template match="appendix/docinfo|appendixinfo"></xsl:template>

</xsl:stylesheet>

