<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template name="element.and.label">
  <xsl:call-template name="label.id">
    <xsl:with-param name="string">
      <xsl:call-template name="sec-map">
        <xsl:with-param name="keyword" select="local-name(.)"/>
      </xsl:call-template>
      <xsl:call-template name="normalize-scape">
        <xsl:with-param name="string" select="title"/>
      </xsl:call-template>
      <xsl:text>}</xsl:text> 
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="label.id">
  <xsl:param name="object" select="."/>
  <xsl:param name="string" select="''"/>
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
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="title.and.label">
  <xsl:call-template name="normalize-scape">
    <xsl:with-param name="string" select="title"/>
  </xsl:call-template>
  <xsl:text>}&#10;</xsl:text> 
  <xsl:call-template name="label.id"/>
</xsl:template>

</xsl:stylesheet>

