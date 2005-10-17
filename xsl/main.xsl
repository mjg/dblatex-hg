<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl"
                version="1.0">

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="/" mode="doc-wrap">
  <xsl:message>
    <xsl:text>*** Warning: the root element is not an article nor a book</xsl:text>
  </xsl:message>
  <xsl:variable name="root">
    <xsl:choose>
    <xsl:when test="part|chapter">
      <book>
        <xsl:copy-of select="node()|@*"/>
      </book>
    </xsl:when>
    <xsl:otherwise>
      <article>
        <xsl:copy-of select="node()|@*"/>
      </article>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:apply-templates select="exsl:node-set($root)/*"/>
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

