<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl"
                version="1.0">

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="*" mode="info.copy">
  <xsl:for-each select="(info
                        |referenceinfo
                        |refentryinfo
                        |articleinfo
                        |sectioninfo
                        |appendixinfo
                        |bibliographyinfo
                        |chapterinfo
                        |sect1info
                        |sect2info
                        |sect3info
                        |sect4info
                        |sect5info
                        |partinfo
                        |prefaceinfo
                        |docinfo)[1]/child::*">
    <xsl:copy-of select=".|@*"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="/" mode="doc-wrap-with">
  <xsl:param name="root"/>
  <xsl:message>
    <xsl:text>*** Warning: element wrapped with </xsl:text>
    <xsl:value-of select="$root"/>
  </xsl:message>

  <xsl:element name="{$root}">
    <!-- Get titles from the node -->
    <xsl:for-each select="node()/title|node()/subtitle|node()/titleabbrev">
      <xsl:copy-of select="."/>
    </xsl:for-each>

    <!-- Take the infos from the node -->
    <xsl:element name="{$root}info">
      <xsl:apply-templates select="node()" mode="info.copy"/>
    </xsl:element>

    <!-- Now the wrapped node -->
    <xsl:copy-of select="node()|@*"/>
  </xsl:element>
</xsl:template>


<xsl:template match="/" mode="doc-wrap">
  <xsl:message>
    <xsl:text>*** Warning: the root element is not an article nor a book</xsl:text>
  </xsl:message>
  <xsl:variable name="root">
    <xsl:choose>
    <xsl:when test="part|chapter">
      <xsl:value-of select="'book'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'article'"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="rnode">
    <xsl:apply-templates select="." mode="doc-wrap-with">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:apply-templates select="exsl:node-set($rnode)/*"/>
</xsl:template>


<xsl:template match="/">
  <xsl:message>
  <xsl:text>XSLT stylesheets DocBook -  LaTeX 2e </xsl:text>
  <xsl:text>(</xsl:text><xsl:value-of select="$version"/><xsl:text>)</xsl:text>
  </xsl:message>
  <xsl:message>===================================================</xsl:message>
  <xsl:choose>
  <xsl:when test="book|article">
    <xsl:apply-templates/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="." mode="doc-wrap"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

