<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |  On redefinit footnote pour pouvoir parser les caracteres de son texte.
 + ############################################################################## -->

<xsl:template match="footnote">
<xsl:call-template name="label.id"/>
<xsl:text>\footnote{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
