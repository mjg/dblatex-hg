<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:template match="keywordset">
<xsl:text>\begin{keywords}&#10;</xsl:text>
  <xsl:apply-templates/>
<xsl:text>\end{keywords}&#10;</xsl:text>
</xsl:template>

<xsl:template match="subjectset"></xsl:template>

</xsl:stylesheet>
