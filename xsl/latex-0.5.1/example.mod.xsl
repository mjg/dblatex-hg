<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<!--############################################################################# 
 |	$Id$
 |- #############################################################################
 |	$Author$
 |														
 |   PURPOSE:
 + ############################################################################## -->


<xsl:template match="example">
<xsl:text>&#10;\begin{example}&#10;</xsl:text>
<xsl:apply-templates />
<xsl:choose> 
	<xsl:when test="title">
		<xsl:text>&#10;\caption{</xsl:text>
			<xsl:call-template name="normalize-scape"> 
			 	<xsl:with-param name="string" select="title"/>
			</xsl:call-template>
		<xsl:text>}&#10;</xsl:text>
	</xsl:when> 
	<xsl:otherwise>
		<xsl:text>&#10;\caption{</xsl:text>
		<xsl:text>RCAS: Please, add a title to examples}&#10;</xsl:text>
	</xsl:otherwise> 
</xsl:choose>
<xsl:call-template name="label.id"/>
<xsl:text>&#10;\end{example}&#10;</xsl:text>
</xsl:template>


<xsl:template match="informalexample">
<xsl:call-template name="informal.object"/>
</xsl:template>

<xsl:template match="example/title"></xsl:template>
</xsl:stylesheet>
