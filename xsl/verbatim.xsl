<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->


<xsl:template match="screen|address|literallayout|literallayout[@class='monospaced']">
<xsl:text>&#10;\begin{verbatim}</xsl:text>
<xsl:apply-templates mode="latex.verbatim"/>
<xsl:text>\end{verbatim}&#10;</xsl:text>
</xsl:template>

<xsl:template match="programlisting">
<xsl:text>&#10;\begin{verbatim}</xsl:text>
<xsl:apply-templates mode="latex.programlisting"/>
<xsl:text>\end{verbatim}&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
