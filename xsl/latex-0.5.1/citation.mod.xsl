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
<!-- todo: biblio-citation-check -->
<xsl:text>\cite{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
