<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$		
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: Math Elements as theorems, lemmas, propositions, etc.
 |	Note: these elements are not part of the DocBook DTD. I have extended
 |    the docbook DTD in order to support this tags, so that's why I have these 
 |	templates here.
 + ############################################################################## -->


<xsl:template match="mathelement">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mathelement/mathproposition">
<xsl:text>\begin{proposition}[</xsl:text>
<xsl:call-template name="normalize-scape">
	<xsl:with-param name="string" select="title"/> 
</xsl:call-template>
<xsl:text>]&#10;</xsl:text>
  <xsl:apply-templates/>
<xsl:text>\end{proposition}&#10;</xsl:text>
</xsl:template>

<xsl:template match="mathelement/maththeorem">
\begin{theorem}[<xsl:copy-of select="normalize-space(title)"/>]
  <xsl:apply-templates/>
\end{theorem}
</xsl:template>

<xsl:template match="mathelement/mathdefinition">
<xsl:variable name="id"> <xsl:call-template name="label.id"/> </xsl:variable>
\begin{definition}[<xsl:copy-of select="normalize-space(title)"/>]
  <xsl:apply-templates/>
\end{definition}
</xsl:template>

<xsl:template match="mathelement/mathlemma">
<xsl:variable name="id"> <xsl:call-template name="label.id"/> </xsl:variable>
\begin{lemma}[<xsl:copy-of select="normalize-space(title)"/>]
  <xsl:apply-templates/>
\end{lemma}
</xsl:template>


<xsl:template match="mathproof">
<xsl:variable name="id"> <xsl:call-template name="label.id"/> </xsl:variable>
\begin{proof}[<xsl:copy-of select="normalize-space(title)"/>]
  <xsl:apply-templates/>
\end{proof}
</xsl:template>

<xsl:template match="mathphrase|mathcondition|mathassertion">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mathelement/*/title">
</xsl:template>

</xsl:stylesheet>
