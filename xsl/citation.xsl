<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="citation">
<xsl:text>\cite{</xsl:text>
<!-- on prend le texte brut : on ne veut pas que "_" devienne "\_" -->
<xsl:value-of select="."/>
<xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
