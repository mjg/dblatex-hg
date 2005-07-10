<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!-- "Latex" parameters -->

<xsl:param name="latex.hyperparam"/>
<xsl:param name="latex.style">docbook</xsl:param>
<xsl:param name="latex.biblio.output">all</xsl:param>
<xsl:param name="latex.bibfiles">''</xsl:param>
<xsl:param name="latex.bibwidelabel">WIDELABEL</xsl:param>
<xsl:param name="latex.output.revhistory">1</xsl:param>
<xsl:param name="latex.figure.position">[htbp]</xsl:param>
<xsl:param name="latex.figure.boxed">0</xsl:param>
<xsl:param name="latex.babel.use">1</xsl:param>
<xsl:param name="latex.babel.language"/>
<xsl:param name="biblioentry.item.separator">, </xsl:param>

<!-- Default behaviour setting -->

<xsl:param name="refentry.xref.manvolnum" select="1"/>
<xsl:param name="refsynopsis.title">Synopsis</xsl:param>
<xsl:param name="refnamediv.title"></xsl:param>
<xsl:param name="funcsynopsis.style">ansi</xsl:param>
<xsl:param name="funcsynopsis.decoration" select="1"/>
<xsl:param name="function.parens">0</xsl:param>
<xsl:param name="classsynopsis.default.language">java</xsl:param>
<xsl:param name="show.comments" select="1"/>

<!-- "Common" parameters -->

<xsl:variable name="author.othername.in.middle" select="1"/>
<xsl:variable name="section.autolabel" select="1"/>
<xsl:variable name="section.label.includes.component.label" select="0"/>
<xsl:variable name="chapter.autolabel" select="1"/>
<xsl:variable name="preface.autolabel" select="0"/>
<xsl:variable name="part.autolabel" select="1"/>
<xsl:variable name="qandadiv.autolabel" select="1"/>
<xsl:variable name="qanda.inherit.numeration" select="1"/>
<xsl:variable name="qanda.defaultlabel">number</xsl:variable>
<xsl:variable name="graphic.default.extension"></xsl:variable>


<xsl:variable name="latex.book.afterauthor">
  <xsl:text>% --------------------------------------------&#10;</xsl:text>
  <xsl:text>\makeindex&#10;</xsl:text>
  <xsl:text>\makeglossary&#10;</xsl:text>
  <xsl:text>% --------------------------------------------&#10;</xsl:text>
</xsl:variable>

<xsl:variable name="latex.book.begindocument">
  <xsl:text>\begin{document}&#10;</xsl:text>
</xsl:variable>

<xsl:variable name="latex.book.end">
  <xsl:text>% --------------------------------------------&#10;</xsl:text>
  <xsl:text>% End of document&#10;</xsl:text>
  <xsl:text>% --------------------------------------------&#10;</xsl:text>
  <xsl:text>\end{document}&#10;</xsl:text>
</xsl:variable>


</xsl:stylesheet>

