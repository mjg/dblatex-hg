<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="bibliography">
<xsl:message>Processing Bibliography</xsl:message>
<xsl:message>Output Mode:  <xsl:value-of select="$latex.biblio.output"/></xsl:message>
<xsl:text>% ------------------------------------------- &#10;</xsl:text>
<xsl:text>%  &#10;</xsl:text>
<xsl:text>%  Bibliography&#10;</xsl:text>
<xsl:text>%  &#10;</xsl:text>
<xsl:text>% -------------------------------------------  &#10;</xsl:text>
<xsl:text>\bibliography{</xsl:text><xsl:value-of select="$latex.bibfiles"/>
<xsl:text>}&#10;</xsl:text>
<xsl:if test="biblientry">
  <xsl:text>\begin{btSect}{}&#10;</xsl:text>
</xsl:if>
<xsl:text>\chapter{</xsl:text>
<xsl:if test="title">
  <xsl:value-of select="title"/>
</xsl:if>
<xsl:text>}&#10;</xsl:text>
<xsl:choose>
<xsl:when test="biblioentry">
  <xsl:text>\begin{bibgroup}&#10;</xsl:text>
  <xsl:text>\begin{thebibliography}{</xsl:text>
  <xsl:value-of select="$latex.bibwidelabel"/>
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>\thispagestyle{fancy}&#10;</xsl:text>
  <xsl:choose>
  <xsl:when test="$latex.biblio.output ='cited'">
    <xsl:apply-templates select="biblioentry" mode="bibliography.cited">
      <xsl:sort select="./abbrev"/>
      <xsl:sort select="./@xreflabel"/>
      <xsl:sort select="./@id"/>
    </xsl:apply-templates>
  </xsl:when>
  <xsl:when test="$latex.biblio.output ='all'">
    <xsl:apply-templates select="biblioentry" mode="bibliography.all">
      <xsl:sort select="./abbrev"/>
      <xsl:sort select="./@xreflabel"/>
      <xsl:sort select="./@id"/>
    </xsl:apply-templates>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="biblioentry">
      <xsl:sort select="./abbrev"/>
      <xsl:sort select="./@xreflabel"/>
      <xsl:sort select="./@id"/>
    </xsl:apply-templates>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;\end{thebibliography}&#10;</xsl:text>
  <xsl:text>\end{bibgroup}&#10;</xsl:text>
  <xsl:text>\end{btSect}&#10;</xsl:text>
</xsl:when>
<xsl:otherwise>
  <xsl:text>\thispagestyle{fancy}&#10;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="bibliodiv"/> 
</xsl:template>


<xsl:template match="bibliodiv">
<xsl:message>Processing Bibliography - Bibliodiv</xsl:message>
<xsl:text>\begin{btSect}{}
\section{</xsl:text>
<xsl:if test="title">
  <xsl:value-of select="title"/>
</xsl:if>
<xsl:text>}
\begin{bibgroup}
\begin{thebibliography}{WIDELA}
</xsl:text>
<xsl:choose>
  <xsl:when test="$latex.biblio.output ='cited'">
    <xsl:apply-templates select="biblioentry" mode="bibliography.cited">
      <xsl:sort select="./abbrev"/>
      <xsl:sort select="./@xreflabel"/>
      <xsl:sort select="./@id"/>
    </xsl:apply-templates>
  </xsl:when>
  <xsl:when test="$latex.biblio.output ='all'">
    <xsl:apply-templates select="biblioentry">
      <xsl:sort select="./abbrev"/>
      <xsl:sort select="./@xreflabel"/>
      <xsl:sort select="./@id"/>
    </xsl:apply-templates>
  </xsl:when>
</xsl:choose>
<xsl:text>\end{thebibliography}
\end{bibgroup}
\end{btSect}
</xsl:text>
</xsl:template>

<xsl:template match="bibliodiv/title"/>

<xsl:template match="biblioentry/title">
<xsl:text>\emph{</xsl:text>
<xsl:apply-templates select="text()"/>
<xsl:text>}</xsl:text>
</xsl:template>

<!-- Moteur de traitement de biblioentry -->

<xsl:template name="biblioentry.output">
<xsl:variable name="biblioentry.tag">
  <xsl:choose>
  <xsl:when test="@xreflabel">
    <xsl:value-of select="normalize-space(@xreflabel)"/> 
  </xsl:when>
  <xsl:when test="abbrev">
    <xsl:apply-templates select="abbrev" mode="bibliography.mode"/> 
  </xsl:when>
  <xsl:when test="@id">
    <xsl:value-of select="normalize-space(@id)"/> 
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>UNKNOWN</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:text>&#10;</xsl:text>
<xsl:text>\bibitem[</xsl:text>
<xsl:call-template name="normalize-scape">
  <xsl:with-param name="string" select="$biblioentry.tag"/>
</xsl:call-template>
<xsl:text>]</xsl:text> 
<xsl:text>{</xsl:text>
<xsl:value-of select="$biblioentry.tag"/>
<xsl:text>}&#10;</xsl:text> 
<xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
<xsl:apply-templates select="title"/>
<xsl:if test="copyright|
              publisher|
              pubdate|
              pagenums|
              isbn|
              issn|
              pubsnumber">
  <xsl:text>, </xsl:text>
  <xsl:apply-templates select="(copyright|
                                publisher|
                                pubdate|
                                pagenums|
                                isbn|
                                issn|
                                pubsnumber)[position()!=last()]"
       mode="bibliography.mode"/> 
  <xsl:apply-templates select="*[last()]" mode="biblio.mode.last"/>
</xsl:if>
<xsl:text>.</xsl:text>
<xsl:call-template name="label.id"/> 
<xsl:text>&#10;</xsl:text>
</xsl:template>


<!-- Action par defaut en mode biblio, dernier element -->

<xsl:template match="*" mode="biblio.mode.last">
  <xsl:apply-templates mode="biblio.mode.last"/>
</xsl:template>

</xsl:stylesheet>
