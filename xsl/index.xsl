<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="indexterm">
  <xsl:text>\index{</xsl:text>
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="./primary"/>
  </xsl:call-template>
  <xsl:if test="./secondary">
    <xsl:text>!</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="./secondary"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="./tertiary">
    <xsl:text>!</xsl:text>
    <xsl:call-template name="normalize-scape">
      <xsl:with-param name="string" select="./tertiary"/>
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
  <xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
