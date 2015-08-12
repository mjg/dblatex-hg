<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="exsl" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX
    ############################################################################ -->
<xsl:param name="footnote.as.endnote" select="0"/>

<xsl:attribute-set name="endnotes.properties.default">
  <xsl:attribute name="package">endnotes</xsl:attribute>

  <!-- No header: endnotes are embedded in another section -->
  <xsl:attribute name="heading">\mbox{}\par</xsl:attribute>

  <!-- Show end notes as a numbered list -->
  <xsl:attribute name="font-size">\normalsize</xsl:attribute>
  <xsl:attribute name="note-format">%
  \leftskip=1.8em\noindent
  \makebox[0pt][r]{\theenmark.~~\rule{0pt}{\baselineskip}}\ignorespaces
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="endnotes.properties"
                   use-attribute-sets="endnotes.properties.default"/>

<!-- ==================================================================== -->

<xsl:template match="footnote">
  <xsl:choose>
  <!-- in forbidden areas, only put the footnotemark. footnotetext will
       follow in the next possible area (foottext mode) -->
  <xsl:when test="ancestor::term|
                  ancestor::title">
    <xsl:text>\footnotemark{}</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\footnote{</xsl:text>
    <xsl:call-template name="label.id">
      <xsl:with-param name="inline" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Table cells are forbidden for footnotes -->
<xsl:template match="footnote[ancestor::entry]">
  <xsl:text>\footnotemark{}</xsl:text>
</xsl:template>

<xsl:template match="footnoteref">
  <!-- Works only with footmisc -->
  <xsl:text>\footref{</xsl:text>
  <xsl:value-of select="@linkend"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- display the text of the footnotes contained in this element -->
<xsl:template match="*" mode="foottext">
  <xsl:variable name="foot" select="descendant::footnote"/>
  <xsl:if test="count($foot)&gt;0">
    <xsl:text>\addtocounter{footnote}{-</xsl:text>
    <xsl:value-of select="count($foot)"/>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates select="$foot" mode="foottext"/>
  </xsl:if>
</xsl:template>

<xsl:template match="footnote" mode="foottext">
  <xsl:text>\stepcounter{footnote}&#10;</xsl:text>
  <xsl:text>\footnotetext{</xsl:text>
  <xsl:apply-templates/>
  <xsl:call-template name="label.id"/>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- in a programlisting do as normal but in tex-escaped pattern -->
<xsl:template match="footnote" mode="latex.programlisting">
  <xsl:param name="co-tagin" select="'&lt;:'"/>
  <xsl:param name="probe" select="0"/>

  <xsl:call-template name="verbatim.embed">
    <xsl:with-param name="co-taging" select="$co-tagin"/>
    <xsl:with-param name="probe" select="$probe"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="*" mode="toc.skip">
  <xsl:apply-templates mode="toc.skip"/>
</xsl:template>

<!-- escape characters as usual -->
<xsl:template match="text()" mode="toc.skip">
  <xsl:apply-templates select="."/>
</xsl:template>

<!-- in this mode the footnotes must vanish -->
<xsl:template match="footnote" mode="toc.skip"/>

<!-- ==================================================================== -->

<xsl:template name="footnote.setup">
  <xsl:if test="$footnote.as.endnote=1">
    <xsl:text>\makeatletter&#10;</xsl:text>
    <xsl:call-template name="endnotes.setup"/>
    <xsl:text>\let\footnote=\endnote&#10;</xsl:text>
    <xsl:text>\let\footnotetext=\endnotetext&#10;</xsl:text>
    <xsl:text>\let\footnotemark=\endnotemark&#10;</xsl:text>
    <xsl:text>\let\c@footnote=\c@endnote&#10;</xsl:text>
    <xsl:text>\makeatother&#10;</xsl:text>
    <!-- Endnotes now uses the footnote counter: prevent from chapter reset -->
    <xsl:text>\usepackage{chngcntr}&#10;</xsl:text>
    <xsl:text>\counterwithout{footnote}{chapter}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Default setup, to remove if already defined in a latex style, or to
     override if another formatting or package is required -->

<xsl:template name="endnotes.setup">
  <xsl:variable name="endnotesetup">
    <endnotesetup xsl:use-attribute-sets="endnotes.properties"/>
  </xsl:variable>
    
  <xsl:apply-templates select="exsl:node-set($endnotesetup)/*"/>
</xsl:template>

<xsl:template match="endnotesetup">
  <xsl:variable name="package">
    <xsl:choose>
    <xsl:when test="@package"><xsl:value-of select="@package"/></xsl:when>
    <xsl:otherwise>endnotes</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>\usepackage{</xsl:text>
  <xsl:value-of select="$package"/>
  <xsl:text>}&#10;</xsl:text>

  <xsl:if test="@heading">
    <xsl:text>\def\enoteheading{</xsl:text>
    <xsl:value-of select="@heading"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="@font-size">
    <xsl:text>\def\enotesize{</xsl:text>
    <xsl:value-of select="@font-size"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="@note-format">
    <xsl:text>\def\enoteformat{</xsl:text>
    <xsl:value-of select="@note-format"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Just append the endnotes to the other content -->
<xsl:template match="*" mode="endnotes">
  <xsl:apply-templates select="*"/>
  <xsl:if test="$footnote.as.endnote=1">
    <xsl:text>\theendnotes&#10;</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
