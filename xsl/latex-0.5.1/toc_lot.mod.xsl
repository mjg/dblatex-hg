<?xml version='1.0'?>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->

<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
	exclude-result-prefixes="doc" version='1.0'>

<xsl:template match="toc">
<xsl:text>&#10;</xsl:text>
<xsl:text>\tableofcontents&#10;</xsl:text>
<xsl:text>\listoffigures&#10;</xsl:text>
</xsl:template>

<xsl:template match="lot|lotentry">
<xsl:text>\listoftables&#10;</xsl:text>
</xsl:template>

<xsl:template match="lotentry"/>
<xsl:template match="tocpart|tocchap|tocfront|tocback|tocentry"/>
<xsl:template match="toclevel1|toclevel2|toclevel3|toclevel4|toclevel5"/>
</xsl:stylesheet>
