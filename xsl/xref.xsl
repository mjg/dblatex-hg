<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE: Elements pointés par xref non traités.
 + ############################################################################## -->

<xsl:template match="step" mode="xref-to">
<xsl:param name="target" select="."/>
<xsl:param name="refelem" select="local-name($target)"/>
<xsl:call-template name="cross-reference">
	<xsl:with-param name="target" select="$target"/>
</xsl:call-template>
</xsl:template>

<!-- Text of endterm xref must be managed with the text() function to support
     the special latex characters -->

<xsl:template match="*" mode="xref.text">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
