<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    Feuille de style de transformation XML DocBook -> LaTeX 
    ############################################################################ -->

<!-- Noting to do: things are done by latex -->
<xsl:template match="toc"/>
<xsl:template match="lot"/>
<xsl:template match="lotentry"/>
<xsl:template match="tocpart|tocchap|tocfront|tocback|tocentry"/>
<xsl:template match="toclevel1|toclevel2|toclevel3|toclevel4|toclevel5"/>

</xsl:stylesheet>
