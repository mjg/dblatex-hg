<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$												
 |														
 |   PURPOSE: Manage Authorgroups 
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<xsl:template match="authorgroup">
<xsl:for-each select="author">
	<xsl:apply-templates select="."/>
        <xsl:if test="not(position()=last())">
        	<xsl:text> \and </xsl:text>
        </xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match="authorinitials">
<xsl:apply-templates/>
<xsl:value-of select="$biblioentry.item.separator"/>
</xsl:template>

</xsl:stylesheet>
