<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX
    ############################################################################ -->

<xsl:template match="footnote">
<xsl:text>\footnote{</xsl:text>
<xsl:call-template name="label.id"/>
<xsl:apply-templates/>
<xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="footnoteref">
<xsl:text>\ref{</xsl:text>
<xsl:value-of select="@linkend"/>
<xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
