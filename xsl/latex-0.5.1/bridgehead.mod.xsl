<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->



<!-- RCAS: Add bridgehead renderas support -->
<xsl:template match="bridgehead">
<xsl:text>&#10;&#10;</xsl:text>
<xsl:text>&#10;\noindent{\bf </xsl:text><xsl:apply-templates/><xsl:text>} \\ &#10;</xsl:text>
<xsl:call-template name="label.id"/>
</xsl:template>

</xsl:stylesheet>
